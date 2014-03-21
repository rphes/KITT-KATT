using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Windows.Threading;

namespace SerialApp
{
	/// <summary>
	/// Provides access to all data periodically measured from KITT as well as modifiers to display this data in the GUI
	/// </summary>
	public class Vehicle : ObservableObject
	{
		#region Data members
		//Status variables
		private int _actualPWMSpeed;

		public int ActualPWMSpeed
		{
			get { return _actualPWMSpeed; }
			set 
			{
				_actualPWMSpeed = value;
				Data.matlab.PutRxData("actualpwmspeed", value);
				//NotifyPropertyChanged("ActualPWMSpeed");
				//NotifyPropertyChanged("ActualPWMSpeedString");
			}
		}

		private int _actualPWMHeading;

		public int ActualPWMHeading
		{
			get { return _actualPWMHeading; }
			set
			{
				_actualPWMHeading = value;
				Data.matlab.PutRxData("actualpwmheading", value);
				//NotifyPropertyChanged("ActualPWMHeading");
				//NotifyPropertyChanged("ActualPWMHeadingString");
			}
		}

		private int _sensorDistanceLeft;

		public int SensorDistanceLeft
		{
			get { return _sensorDistanceLeft; }
			set
			{
				_sensorDistanceLeft = value;
				Data.matlab.PutRxData("current_dist_left", value);
				//NotifyPropertyChanged("SensorDistanceLeft");
				//NotifyPropertyChanged("SensorDistanceLeftString");
			}
		}

		private int _sensorDistanceRight;

		public int SensorDistanceRight
		{
			get { return _sensorDistanceRight; }
			set
			{
				_sensorDistanceRight = value;
				Data.matlab.PutRxData("current_dist_right", value);
				//NotifyPropertyChanged("SensorDistanceRight");
				//NotifyPropertyChanged("SensorDistanceRightString");
			}
		}

		private int _batteryVoltage;

		public int BatteryVoltage
		{
			get { return _batteryVoltage; }
			set
			{
				_batteryVoltage = value;
				Data.matlab.PutRxData("battery_voltage", value);
				//NotifyPropertyChanged("BatteryVoltage");
				//NotifyPropertyChanged("BatteryVoltageString");
				//NotifyPropertyChanged("BatteryPercentageString");
			}
		}

		public bool AudioStatus { get; set; }
		#endregion
	}
}
