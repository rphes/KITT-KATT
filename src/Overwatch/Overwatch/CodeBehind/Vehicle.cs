using System;
using System.Windows;

namespace Overwatch
{
	/// <summary>
	/// Holds all vehicle-specific data
	/// </summary>
	public class Vehicle
	{
		#region Data members
		#region Global constants
		#region Physical parameters
		public static double Width { get { return 0.3; } }
		public static double Height { get { return 0.4; } }
		public static double Mass { get { return 0.5; } }
		public static double RollingResistance { get { return 0.15; } }
		public static double MotorInductance { get { return 0.02; } }
		public static double MotorConstant { get { return 0.5; } }
		public static double MotorResistance { get { return 0.1; } }
		public static double GearRatio { get { return 20; } }
		public static double WheelRadius { get { return 0.15; } }
		#endregion

		#region Speed and heading
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
		#endregion

		#region Sensors
		public static int SensorMinRange { get { return 0; } }
		public static int SensorMaxRange { get { return 300; } }
		#endregion

		#region Battery
		public static int BatteryVoltageMin { get { return 0; } }
		public static int BatteryVoltageMax { get { return 20000; } }
		#endregion
		#endregion

		#region Status variables
		#region Position
		public double X { get; set; } //from 0 to 1
		public double Y { get; set; } //from 0 to 1
		public Point Position { get { return new Point(X, Y); } }
		public double Angle { get; set; }
		#endregion

		#region Speed and heading
		public int ActualPWMSpeed { get; set; }
		public int ActualPWMHeading { get; set; }
		public double Velocity { get; set; }
		#endregion

		#region Sensors
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
		#endregion

		#region Battery
		public int BatteryVoltage { get; set; }
		#endregion

		#region Beacon
		public bool BeaconIsEnabled { get; set; }
		#endregion
		#endregion
		#endregion
	}
}
