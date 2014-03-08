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
			protected set 
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
			protected set
			{
				_actualPWMHeading = value;
				NotifyPropertyChanged("ActualPWMHeading");
				NotifyPropertyChanged("ActualPWMHeadingString");
			}
		}

		public int SensorDistanceLeft { get; set; }
		public int SensorDistanceRight { get; set; }
		public double BatteryVoltage { get; set; }
		public bool AudioStatus { get; set; }

		//UI helpers
		public string ActualPWMSpeedString { get { return "Actual PWM Speed: " + ActualPWMSpeed; } }
		public string ActualPWMHeadingString { get { return "Actual PWM Heading: " + ActualPWMHeading; } }
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
