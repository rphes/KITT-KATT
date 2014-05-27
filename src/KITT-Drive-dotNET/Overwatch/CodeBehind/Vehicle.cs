using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Windows.Threading;

namespace Overwatch
{
	/// <summary>
	/// Provides access to all data periodically measured from KITT as well as modifiers to display this data in the GUI
	/// </summary>
	public class Vehicle
	{
		#region Data members
		//Status variables
		public int ActualPWMSpeed { get; set; }
		public int ActualPWMHeading { get; set; }

		private int _sensorDistanceLeft;
		public int SensorDistanceLeft 
		{ 
			get { return _sensorDistanceLeft; }
			set { _sensorDistanceLeft = (int)Math.Round(Data.Clamp(value, Data.SensorMinRange, Data.SensorMaxRange)); }
		}

		private int _sensorDistanceRight;
		public int SensorDistanceRight
		{
			get { return _sensorDistanceRight; }
			set { _sensorDistanceRight = (int)Math.Round(Data.Clamp(value, Data.SensorMinRange, Data.SensorMaxRange)); }
		}
		public int BatteryVoltage { get; set; }
		public bool BeaconIsEnabled { get; set; }
		#endregion
	}
}
