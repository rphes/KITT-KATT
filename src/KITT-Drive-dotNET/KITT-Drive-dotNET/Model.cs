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
		DateTime tZero;
		TimeSpan tRel { get { return DateTime.Now - tZero; } }
		TimeSpan tMax = new TimeSpan(0, 0, 30);
		TimeSpan tInit = new TimeSpan(0, 0, 0);
		int iteration = 0;

		//Reference
		int[] refVal = { 100, 200, 50 }; //in cm
		int[] refTimes = { 10, 20, 30 }; //in seconds

		//Throttle scaling
		double thScaleForward = 1;
		double thScaleBackward = 1;
		double thMaxForward = 15;
		double thMinForward = 5;
		double thMaxBackward = -15;
		double thMinBackward = -5;

		//Low-pass filter
		double[] lowPass = new double[3];
		double fFall = 10;
		double tExpectedSample = 0.3;
	
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
			if (iteration == 0)
			{
				tZero = DateTime.Now;
				lowPass = makeLowPass();
			}

			double T = iteration * tInterval.TotalSeconds;//tRel.TotalSeconds;

			//System.Diagnostics.Debug.WriteLine("Current time: " + tRel);
			
			if (controlling == 0 && T > tInit.TotalSeconds)
				controlling = 1;

			//Controller
			if (iteration > 0)
			{
				double yNext = Math.Min(Data.Car.SensorDistanceLeft, Data.Car.SensorDistanceRight);

				//Determine next reference value
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

				//Set next y
				y = yNext;
			}

			//Drive signal scaling
			if (drive < 0)
			{
				drive *= thScaleBackward;
				drive = Data.Clamp(drive, thMinBackward, thMaxBackward);
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
	}
}
