using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;

namespace KITT_Drive_dotNET
{
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
				NotifyPropertyChanged("ActualPWMSpeed");
				NotifyPropertyChanged("ActualPWMSpeedString");
			}
		}

		private int _actualPWMHeading;

		public int ActualPWMHeading
		{
			get { return _actualPWMHeading; }
			set
			{
				_actualPWMHeading = value;
				NotifyPropertyChanged("ActualPWMHeading");
				NotifyPropertyChanged("ActualPWMHeadingString");
			}
		}

		private int _sensorDistanceLeft;

		public int SensorDistanceLeft
		{
			get { return _sensorDistanceLeft; }
			set
			{
				_sensorDistanceLeft = value;
				NotifyPropertyChanged("SensorDistanceLeft");
				NotifyPropertyChanged("SensorDistanceLeftString");
			}
		}

		private int _sensorDistanceRight;

		public int SensorDistanceRight
		{
			get { return _sensorDistanceRight; }
			set
			{
				_sensorDistanceRight = value;
				NotifyPropertyChanged("SensorDistanceRight");
				NotifyPropertyChanged("SensorDistanceRightString");
			}
		}

		private int _batteryVoltage;

		public int BatteryVoltage
		{
			get { return _batteryVoltage; }
			set
			{
				_batteryVoltage = value;
				NotifyPropertyChanged("BatteryVoltage");
				NotifyPropertyChanged("BatteryVoltageString");
				NotifyPropertyChanged("BatteryPercentageString");
			}
		}

		public bool AudioStatus { get; set; }

		//UI helpers
		public string ActualPWMSpeedString { get { return "Actual PWM Speed: " + ActualPWMSpeed; } }
		public string ActualPWMHeadingString { get { return "Actual PWM Heading: " + ActualPWMHeading; } }
		public string SensorDistanceLeftString { get { return "Left: " + SensorDistanceLeft + " cm"; } }
		public string SensorDistanceRightString { get { return "Right: " + SensorDistanceRight + " cm"; } }
		public string BatteryVoltageString { get { return BatteryVoltage + " mV"; } }
		public string BatteryPercentageString { get { return Math.Round(((double)BatteryVoltage / Data.BatteryVoltageMax * 100)).ToString() + " %"; } }
		#endregion

		#region Construction
		public Vehicle()
		{
			ActualPWMSpeed = Data.PWMSpeedDefault;
			ActualPWMHeading = Data.PWMHeadingDefault;
		}
		#endregion
	}
}
