using MathNet.Numerics.LinearAlgebra.Double;
using MathNet.Numerics.LinearAlgebra.Generic;
using OxyPlot;
using System;
using System.Collections.Generic;
using System.Windows.Threading;

namespace KITT_Drive_dotNET
{
	/// <summary>
	/// Implements a system model, for tracking and controlling KITT
	/// </summary>
	public abstract class AutoControl
	{
		#region Data members
		//KITT parameters

		//Model essentials
		protected Matrix<double> A;
		protected Matrix<double> B;
		protected Matrix<double> C;
		protected Matrix<double> D;
		protected Matrix<double> K; //Feedback gain
		protected Matrix<double> L; //Observer gain
		protected Matrix<double> x; //State matrix
		protected Matrix<double> xRef //Reference state matrix
		{
			get
			{
				double val = 0;
				for (int i = 0; i < xRefList.Count; i++)
				{
					if (tTotal.TotalSeconds >= tRefList[i])
						val = (double)xRefList[i] / 100;
					else
						break;
				}
				Matrix<double> m = new DenseMatrix(A.RowCount, 1);
				m.At(0, 0, val);
				return m;
			}
		}
		protected double y = 0; //Vehicle output
		protected double t = 0; //Current time
		protected int v = 0; //Calculated vehicle reference speed
		protected const int numsteps = 100;

		//Time properties
		protected DateTime tPrevious;
		protected TimeSpan tDelta;
		protected TimeSpan tInit = new TimeSpan(0, 0, 0, 0);
		protected TimeSpan tTotal;
		protected int iteration = 0;
		
		//Reference
		public List<int> xRefList { get; set; }
		public List<int> tRefList { get; set; }

		//Throttle mapping
		protected double[] forceMapper = { 10, 0, -0.025 };
		protected double forceMin = 0.02;

		//Filtering
		public bool LowPassFilterIsEnabled { get; set; }
		public bool ExpectedValueFilterIsEnabled { get; set; }
		protected double[] lowPass = new double[3];
		protected double fFall = 100; //Cut-off frequency of low-pass filter
		protected double tExpectedSample = 0.05; //Expected sample time for dimensioning low-pass filter
		protected List<double> dLeft = new List<double>(4); //Historic left sensor values
		protected List<double> dRight = new List<double>(4); //Historic right sensor values
		protected double maxDeviation = 0.5;

		//Plot data
		protected DispatcherTimer evTimer;
		protected TimeSpan tInterval = new TimeSpan(0, 0, 0, 0, 100);
		protected int tick = 0;
		public double MaxTimeSpan { get { return 10; } }
		public int MaxDataPoints { get { return (int)(MaxTimeSpan / tInterval.TotalSeconds); } }
		public int MaxPlotDataPoints { get { return (int)Math.Round(MaxDataPoints * 1.2); } }
		public List<double> TBuffer { get; set; } //Stores time points (x-values)
		public List<double> YBuffer { get; set; } //Stores sensor distance points
		public List<double> VBuffer { get; set; } //Stores output speed points
		public List<double> RBuffer { get; set; } //Stores reference distance points

		//Misc
		protected short controlling = 0; //Modifier for enabling vehicle control
		protected bool running = false;

		#endregion

		#region Construction
		public AutoControl()
		{
			//Init timer
			evTimer = new DispatcherTimer();
			evTimer.Tick += evTimer_Tick;
			evTimer.Interval = tInterval;

			//Disable filters by default
			LowPassFilterIsEnabled = false;
			ExpectedValueFilterIsEnabled = false;
		}
		#endregion

		#region Event handlers
		protected void evTimer_Tick(object sender, EventArgs e)
		{
			//Get total execution time
			t = tick * tInterval.TotalSeconds;
			tick++;

			//UpdateModel();
			updatePlotData();

		}
		public void UpdateModel()
		{
			if (!running)
				return;

			control();
			iteration++;
			Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();
		}
		#endregion

		#region Methods
		public void Start()
		{
			//Reset or initialise values
			tick = 0;
			iteration = 0;
			tPrevious = DateTime.Now;
			t = 0;
			v = 0;
			y = 0;
			tTotal = new TimeSpan(0);
			dLeft = new List<double>(3);
			dRight = new List<double>(3);

			//Request initial status
			Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();

			//Initialise some stuff
			x = new DenseMatrix(A.RowCount, 1);
			lowPass = makeLowPass();

			//Empty or initialise plot buffers
			TBuffer = new List<double>(MaxPlotDataPoints);
			YBuffer = new List<double>(MaxPlotDataPoints);
			VBuffer = new List<double>(MaxPlotDataPoints);
			RBuffer = new List<double>(MaxPlotDataPoints);

			//Enable everything
			running = true;
			
			//Start plot updater
			evTimer.Start();		
		}

		public void Stop()
		{
			evTimer.Stop();
			running = false;
		}

		protected void control()
		{
			double force = 0;

			tDelta = DateTime.Now - tPrevious;
			tTotal += tDelta;
			t = tTotal.TotalSeconds;
			tPrevious = DateTime.Now;

			//Check if the observer is done initializing
			if (controlling == 0 && t > tInit.TotalSeconds)
				controlling = 1;

			//Obtain current filtered working distance
			y = Math.Min(filter((double)Data.MainViewModel.VehicleViewModel.SensorDistanceLeft / 100, ref dLeft), filter((double)Data.MainViewModel.VehicleViewModel.SensorDistanceRight / 100, ref dRight));

			//Calculate new states and control
			if (iteration > 0)
			{
				//Find next state
				for (int i = 0; i < numsteps; i++ )
				{
					//Find next slope
					Matrix<double> curSlope = getSlope(x);

					//Find next predicted value via Euler's method
					Matrix<double> predVal = x + curSlope * tDelta.TotalSeconds;

					//Find next predicted slope
					Matrix<double> predSlope = getSlope(predVal);

					x += tDelta.TotalSeconds / numsteps / 2 * (curSlope + predSlope);
				}					

				force = (controlling * K * (x - xRef)).At(0, 0);
			}

			//Map force to PWM-value
			v = map(force);
			Data.MainViewModel.ControlViewModel.Speed = v;
		}

		virtual protected Matrix<double> getSlope(Matrix<double> var)
		{
			return	
				(A - L * C - B * K * controlling) * var + //(A - BK - LC)x
				B * K * xRef * controlling + // B K xRef
				L * y; //Ly
		}

		protected double[] makeLowPass()
		{
			double c1, c2, c3;
			double a = 1 / (2 * Math.PI * fFall * tExpectedSample);
			c1 = 2 * (Math.Pow(a, 2) + a) / (Math.Pow(a, 2) + 2 * a + 1);
			c2 = Math.Pow(-a, 2) / (Math.Pow(a, 2) + 2 * a + 1);
			c3 = 1 / (Math.Pow(a, 2) + 2 * a + 1);

			return new double[] { c1, c2, c3 };
		}

		protected double filter(double value, ref List<double> history)
		{
			int count = history.Count;
			double filtered, expected;

			filtered = value;

			//Unrealistic value filter based on historic values
			if (ExpectedValueFilterIsEnabled)
			{
				if (count == 3)
				{
					expected = 2.5 * history[count - 1] - 2 * history[count - 2] + 0.5 * history[count - 3];

					if (Math.Abs(value - expected) > maxDeviation)
						filtered = expected;
				}
			}
			
			//Low-pass filter
			if (LowPassFilterIsEnabled)
			{
				filtered *= lowPass[2];

				if (count > 0)
					filtered += lowPass[0] * history[count - 1];
				if (count > 1)
					filtered += lowPass[1] * history[count - 2];
			}

			//Remove obsolete value and save new one
			if (count == 3)
				history.RemoveAt(0);
			if (iteration > 0)
				history.Add(filtered);

			return filtered;
		}

		protected int map(double force)
		{
			if (Math.Abs(force) < forceMin)
				return Data.SpeedDefault;
			else
			{
				double f;
				if (force > 0)
				{
					f = force - forceMin;
					return (int)Math.Round(6 + forceMapper[0] * f + forceMapper[1] * Math.Pow(f, 2) + forceMapper[2] * Math.Pow(f, 3));
				}
				else
				{
					f = force + forceMin;
					return (int)Math.Round(-6 + forceMapper[0] * f + forceMapper[1] * Math.Pow(f, 2) + forceMapper[2] * Math.Pow(f, 3));
				}
			}
		}

		protected void updatePlotData()
		{
			//Update graph data
			TBuffer.Add(t);
			YBuffer.Add(y * 100);
			VBuffer.Add(v);
			RBuffer.Add(xRef.At(0, 0) * 100);
			if (TBuffer.Count == MaxPlotDataPoints)
			{
				TBuffer.RemoveAt(0);
				YBuffer.RemoveAt(0);
				VBuffer.RemoveAt(0);
				RBuffer.RemoveAt(0);
			}

			Data.MainViewModel.AutoControlViewModel.UpdatePlot();

			//Ping
			Data.MainViewModel.AutoControlViewModel.UpdateBinding("PingString");
		}
		#endregion
	}
}
