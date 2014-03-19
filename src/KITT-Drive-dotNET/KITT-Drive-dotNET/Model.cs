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
	public class Model
	{
		#region Data members
		//Model essentials
		Matrix<double> A = DenseMatrix.OfArray(new double[,] { { 0, 1 }, { -0.07233, -3.4955 } });
		Matrix<double> B = DenseMatrix.OfArray(new double[,] { { 1.6339 }, { -8.2873 } });
		Matrix<double> C = DenseMatrix.OfArray(new double[,] { { 1, 0 } });
		Matrix<double> K = DenseMatrix.OfArray(new double[,] { { -0.1007, 0.2692 } }); //Feedback gain
		Matrix<double> L = DenseMatrix.OfArray(new double[,] { { 3.2045 }, { -0.0537 } }); //Observer gain
		Matrix<double> R { get { return (C * (B * K - A).Inverse() * B).Inverse(); } } //Control input scale
		Matrix<double> x = DenseMatrix.OfArray(new double[,] { { 1 }, { 0 } }); //State matrix
		double y = 0; //Vehicle output
		double r = 0; //Control input
		double drive; //Unscaled throttle

		//Model re-evaluation timer
		public DispatcherTimer evTimer;
		TimeSpan tInterval = new TimeSpan(0, 0, 0, 0, 100);
		//DateTime tZero; //obsolete at this point, see tRel
		//TimeSpan tRel { get { return DateTime.Now - tZero; } } //obsolete at this point, when using a fixed sampletime it's easier to use that as reference
		TimeSpan tMax = new TimeSpan(0, 0, 30);
		TimeSpan tInit = new TimeSpan(0, 0, 0);
		int iteration = 0;

		//Reference
		int[] refVal = { 100, 200, 50 }; //in cm
		int[] refTimes = { 10, 20, 30 }; //in seconds

		//Throttle scaling
		double thScaleForward = 15;
		double thScaleBackward = 15;
		double thMaxForward = 15;
		double thMinForward = 5;
		double thMaxBackward = -15;
		double thMinBackward = -5;

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

		public Model()
		{
			evTimer = new DispatcherTimer();
			evTimer.Tick += EvTimer_Tick;
			evTimer.Interval = tInterval;
		}

		void EvTimer_Tick(object sender, EventArgs e)
		{
			//Init some stuff
			if (iteration == 0)
			{
				//tZero = DateTime.Now; //unused (yet?)
				lowPass = makeLowPass();
			}

			//Get total execution time
			double T = iteration * tInterval.TotalSeconds;

			//Check if the observer is done initializing
			if (controlling == 0 && T > tInit.TotalSeconds)
				controlling = 1;

			//Obtain current filtered working distance
			y = Math.Min(filter(Data.Car.SensorDistanceLeft, ref dLeft), filter(Data.Car.SensorDistanceRight, ref dRight));

			//Control
			if (iteration > 0)
			{
				//Determine reference value
				for (int i = 0; i < refVal.Length; i++)
				{
					if (T < refTimes[i])
					{
						r = refVal[i] / 100; //to meters
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

				//Drive!
				drive = (controlling * R * r - K * x).At(0,0);
			}

			//Drive signal scaling
			if (drive < 0)
			{
				drive *= thScaleBackward;
				drive = Data.Clamp(drive, thMaxBackward, thMinBackward);
			}
			else if (drive > 0)
			{
				drive *= thScaleForward;
				drive = Data.Clamp(drive, thMinForward, thMaxForward);
			}
			else
				drive = 0;

			//Drive KITT!
			Data.Ctr.Speed = drive;


			//Update internal state and save required values
			iteration++;
		}

		Matrix<double> getSlope(Matrix<double> var)
		{
			return	
				(A - L * C - B * K * controlling) * var + //(A - BK - LC)x
				B * R * r * controlling + // BRr
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

		double filter(double value, ref List<double> history)
		{
			double filtered, expected;

			filtered = value;

			//Unrealistic value filter based on historic values
			if (iteration > 2)
			{
				expected = 0.2 * history[0] - 2 * history[1] + 0.5 * history[2];

				if (Math.Abs(value - expected) > 0.5)
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
	}
}
