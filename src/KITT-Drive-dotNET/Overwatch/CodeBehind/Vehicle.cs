using System;
using System.Windows;

namespace Overwatch
{
	/// <summary>
	/// Provides access to all data periodically measured from KITT as well as modifiers to display this data in the GUI
	/// </summary>
	public class Vehicle
	{
		#region Data members
		#region Global constants
		//Physical parameters
		public static double Width { get { return 0.3; } }
		public static double Height { get { return 0.4; } }
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

		#region Status variables
		//Position
		public double X { get; set; } //from 0 to 1
		public double Y { get; set; } //from 0 to 1
		public Point Position { get { return new Point(X, Y); } }

		//Speed and heading
		public int ActualPWMSpeed { get; set; }
		public int ActualPWMHeading { get; set; }

		//Sensors
		private int _sensorDistanceLeft;
		public int SensorDistanceLeft 
		{ 
			get { return _sensorDistanceLeft; }
			set { _sensorDistanceLeft = (int)Math.Round(Data.Clamp(value, SensorMinRange, SensorMaxRange)); }
		}

		private int _sensorDistanceRight;
		public int SensorDistanceRight
		{
			get { return _sensorDistanceRight; }
			set { _sensorDistanceRight = (int)Math.Round(Data.Clamp(value, SensorMinRange, SensorMaxRange)); }
		}

		//Battery
		public int BatteryVoltage { get; set; }

		//Beacon
		public bool BeaconIsEnabled { get; set; }	
		#endregion
		#endregion
	}
}
