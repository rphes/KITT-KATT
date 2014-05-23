using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Overwatch.ViewModel;

namespace Overwatch
{
	public static class Data
	{
		#region Global constants
		//Physical parameters
		public static double Mass { get { return 0.5; } }
		public static double RollingResistance { get { return 0.15; } }
		public static double MotorInductance { get { return 0.02; } }
		public static double MotorConstant { get { return 0.5; } }
		public static double MotorResistance { get { return 0.1; } }
		public static double GearRatio { get { return 20; } }
		public static double WheelRadius { get { return 0.15; } }

		//Speed and heading
		public static int SpeedMin { get { return -15; } }
		public static int SpeedMax { get { return 15; } }
		public static int HeadingMin { get { return -50; } }
		public static int HeadingMax { get { return 50; } }
		public static int SpeedDefault { get { return 0; } }
		public static int HeadingDefault { get { return 0; } }
		public static int PWMOffset { get { return 150; } }
		public static int PWMSpeedMin { get { return SpeedMin + PWMOffset; } }
		public static int PWMSpeedMax { get { return SpeedMax + PWMOffset; } }
		public static int PWMHeadingMin { get { return HeadingMin + PWMOffset; } }
		public static int PWMHeadingMax { get { return HeadingMax + PWMOffset; } }
		public static int PWMSpeedDefault { get { return SpeedDefault + PWMOffset; } }
		public static int PWMHeadingDefault { get { return HeadingDefault + PWMOffset; } }
		//Sensors
		public static int SensorMinRange { get { return 0; } }
		public static int SensorMaxRange { get { return 300; } }
		//Battery
		public static int BatteryVoltageMin { get { return 0; } }
		public static int BatteryVoltageMax { get { return 20000; } }
		#endregion

		#region Modules
		public static MainViewModel MainViewModel = new MainViewModel();
		#endregion

		#region Utility methods
		public static double Clamp(double value, double min, double max)
		{
			if (value > max)
				return max;
			if (value < min)
				return min;
			return value;
		}

		public static double Snap(double value, double snap, double min, double max)
		{
			if (value < max && value > min)
				return snap;
			else
				return value;
		}
		#endregion
	}

	public enum Direction
	{
		up, down, left, right
	}


}
