using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MathNet.Numerics.LinearAlgebra.Generic;
using MathNet.Numerics.LinearAlgebra.Double;
using System.Windows.Threading;

namespace KITT_Drive_dotNET
{
	/// <summary>
	/// Implements a system model, for tracking and controlling KITT
	/// </summary>
	public class AutoPilot
	{
		#region Data members
		//KITT parameters

		//Model essentials
		Matrix<double> A;
		Matrix<double> B;
		Matrix<double> C;
		Matrix<double> K; //Feedback gain
		Matrix<double> L; //Observer gain
		Matrix<double> x = DenseMatrix.OfArray(new double[,] { { 1 }, { 0 } }); //State matrix
		Matrix<double> xRef = DenseMatrix.OfArray(new double[,] { { 0 }, { 0 } }); //Reference state matrix
		double y = 0; //Vehicle output

		//Model re-evaluation timer
		DispatcherTimer evTimer;
		TimeSpan tInterval = new TimeSpan(0, 0, 0, 0, 100);
		//DateTime tZero; //obsolete at this point, see tRel
		//TimeSpan tRel { get { return DateTime.Now - tZero; } } //obsolete at this point, when using a fixed sampletime it's easier to use that as reference
		TimeSpan tMax = new TimeSpan(0, 0, 30);
		TimeSpan tInit = new TimeSpan(0, 0, 0);
		int iteration = 0;

		//Reference
		int[] refVal = { 100, 200, 50 }; //in cm
		int[] refTimes = { 10, 20, 30 }; //in seconds

		//Throttle mapping
		double[] forceMapper = {1, 0, -0.025};
		double forceMin = 0.1;

		//Filtering
		double[] lowPass = new double[3];
		double fFall = 10; //Cut-off frequency of low-pass filter
		double tExpectedSample = 0.3; //Expected sample time for dimensioning low-pass filter
		List<double> dLeft = new List<double>(4); //Historic left sensor values
		List<double> dRight = new List<double>(4); //Historic right sensor values
		double maxDeviation = 0.5;
	
		//Misc
		short controlling = 0; //Modifier for enabling vehicle control

		#endregion

		#region Construction
		public AutoPilot()
		{
			evTimer = new DispatcherTimer();
			evTimer.Tick += evTimer_Tick;
			evTimer.Interval = tInterval;

			A = DenseMatrix.OfArray(new double[,] { { 0, 1 }, { 0, -Data.Rho / Data.Mass } });
			B = DenseMatrix.OfArray(new double[,] { { 0 }, { 1 / Data.Mass } });
			C = DenseMatrix.OfArray(new double[,] { { 1, 0 } });
			K = DenseMatrix.OfArray(new double[,] { { 0.54, 1.65 } }); //acker(A, B, [-0.6 -0.6]) in MATLAB
			L = DenseMatrix.OfArray(new double[,] { { 3.9 }, { 3.61 } }); //acker(A', C', [-2 -2]') in MATLAB
		}
		#endregion

		#region Event handlers
		void evTimer_Tick(object sender, EventArgs e)
		{
			double force;
			int speed;

			//Obtain current filtered working distance
			y = Math.Min(filter(Data.MainViewModel.VehicleViewModel.SensorDistanceLeft, ref dLeft), filter(Data.MainViewModel.VehicleViewModel.SensorDistanceRight, ref dRight));

			//Perform control routines
			force = control();

			//Map force to PWM-value
			speed = map(force);
			Data.MainViewModel.ControlViewModel.Speed = speed;

			//Update internal state and save required values
			iteration++;
		}
		#endregion

		#region Methods
		public void Start()
		{
			x = DenseMatrix.OfArray(new double[,] { { 0 }, { 0 } });
			xRef = DenseMatrix.OfArray(new double[,] { { 0 }, { 0 } }); //TODO actually init this to the wanted values
			lowPass = makeLowPass();
			evTimer.Start();
		}

		Matrix<double> getSlope(Matrix<double> var)
		{
			return	
				(A - L * C - B * K * controlling) * var + //(A - BK - LC)x
				B * K * xRef * controlling + // B K xRef
				L * y; //Ly
		}

		double[] makeLowPass()
		{
			double c1, c2, c3;
			double a = 1 / (2 * Math.PI * fFall * tExpectedSample);
			c1 = 2 * (Math.Pow(a, 2) + a) / (Math.Pow(a, 2 + 2 * a + 1));
			c2 = Math.Pow(-a, 2) / (Math.Pow(a, 2) + 2 * a + 1);
			c3 = 1 / (Math.Pow(a, 2) + 2 * a + 1);

			return new double[] { c1, c2, c3 };
		}

		double control()
		{
			//Get total execution time
			double T = iteration * tInterval.TotalSeconds;

			//Check if the observer is done initializing
			if (controlling == 0 && T > tInit.TotalSeconds)
				controlling = 1;

			//Calculate new states and control
			if (iteration > 0)
			{
				//Determine reference value
				for (int i = 0; i < refVal.Length; i++)
				{
					if (T < refTimes[i])
					{
						xRef.At(0, 0, refVal[i] / 100);
						break;
					}
				}

				//Find next slope
				Matrix<double> curSlope = getSlope(x);

				//Find next predicted value via Euler's method
				Matrix<double> predVal = x + curSlope * tInterval.TotalSeconds;

				//Find next predicted slope
				Matrix<double> predSlope = getSlope(predVal);

				//Find next state
				x += tInterval.TotalSeconds / 2 * (curSlope + predSlope);
				//System.Diagnostics.Debug.WriteLine("x: " + x);

				return (controlling * -K * (x - xRef)).At(0, 0); //TODO check this
			}
			else
				return 0;
		}

		double filter(double value, ref List<double> history)
		{
			double filtered, expected;

			filtered = value;

			//Unrealistic value filter based on historic values
			if (iteration > 2)
			{
				expected = 0.2 * history[0] - 2 * history[1] + 0.5 * history[2];

				if (Math.Abs(value - expected) > maxDeviation)
					filtered = expected;
			}
			
			//Low-pass filter
			filtered *= lowPass[2];

			if (iteration > 0)
				filtered += lowPass[0] * history[0];
			if (iteration > 1)
				filtered += lowPass[1] * history[1];

			//Remove obsolete value and save new one
			if (history.Count == 4)
				history.RemoveAt(3);
			history.Insert(0, filtered);

			return filtered;
		}

		int map(double force)
		{
			if (Math.Abs(force) < forceMin)
				return Data.PWMSpeedDefault;
			else
			{
				double f;
				if (force > 0)
				{
					f = force - forceMin;
					return (int)Math.Round(5 + forceMapper[0] * f + forceMapper[1] * Math.Pow(f, 2) + forceMapper[2] * Math.Pow(f, 3));
				}
				else
				{
					f = force + forceMin;
					return (int)Math.Round(-5 + forceMapper[0] * f + forceMapper[1] * Math.Pow(f, 2) + forceMapper[2] * Math.Pow(f, 3));
				}
			}
		}
		#endregion
	}
}
