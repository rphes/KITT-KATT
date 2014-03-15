using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KITT_Drive_dotNET
{
	public static class Data
	{
		#region Global constants
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
		public static int SensorMaxRange { get { return 200; } }
		//Battery
		public static int BatteryVoltageMin { get { return 0; } }
		public static int BatteryVoltageMax { get { return 20000; } }
		#endregion

		#region Modules
		public static Vehicle Car = new Vehicle();
		public static Control Ctr = new Control();
		public static SerialInterface Com = new SerialInterface();
		#endregion
	}

	public enum Direction
	{
		up, down, left, right
	}
}
