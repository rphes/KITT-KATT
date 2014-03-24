using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Windows.Threading;

namespace KITT_Drive_dotNET
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
		public int SensorDistanceLeft { get; set; }
		public int SensorDistanceRight { get; set; }
		public int BatteryVoltage { get; set; }
		public bool AudioStatus { get; set; }
		#endregion
	}
}
