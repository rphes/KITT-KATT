using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Threading;

namespace Overwatch.ViewModel
{
	public class VehicleViewModel : ObservableObject
	{
		#region Data members
		//Model
		private Vehicle _vehicle = new Vehicle();

		public Vehicle Vehicle
		{
			get { return _vehicle; }
			set { _vehicle  = value; }
		}
		
		//Status variables
		public int ActualPWMSpeed
		{
			get { return Vehicle.ActualPWMSpeed; }
			set
			{
				Vehicle.ActualPWMSpeed = value;
				RaisePropertyChanged("ActualPWMSpeed");
				RaisePropertyChanged("ActualPWMSpeedString");
			}
		}
		public int ActualPWMHeading
		{
			get { return Vehicle.ActualPWMHeading; }
			set
			{
				Vehicle.ActualPWMHeading = value;
				RaisePropertyChanged("ActualPWMHeading");
				RaisePropertyChanged("ActualPWMHeadingString");
			}
		}

		public int SensorDistanceLeft
		{
			get { return Vehicle.SensorDistanceLeft; }
			set
			{
				Vehicle.SensorDistanceLeft = value;
				RaisePropertyChanged("SensorDistanceLeft");
				RaisePropertyChanged("SensorDistanceLeftString");
			}
		}

		public int SensorDistanceRight
		{
			get { return Vehicle.SensorDistanceRight; }
			set
			{
				Vehicle.SensorDistanceRight = value;
				RaisePropertyChanged("SensorDistanceRight");
				RaisePropertyChanged("SensorDistanceRightString");
			}
		}

		public int BatteryVoltage
		{
			get { return Vehicle.BatteryVoltage; }
			set
			{
				Vehicle.BatteryVoltage = value;
				RaisePropertyChanged("BatteryVoltage");
				RaisePropertyChanged("BatteryVoltageString");
				RaisePropertyChanged("BatteryPercentageString");
			}
		}

		public bool BeaconIsEnabled
		{
			get { return Vehicle.BeaconIsEnabled; }
			set { Vehicle.BeaconIsEnabled = value; }
		}

		public string ActualPWMSpeedString { get { return "Actual PWM Speed: " + Vehicle.ActualPWMSpeed; } }
		public string ActualPWMHeadingString { get { return "Actual PWM Heading: " + Vehicle.ActualPWMHeading; } }
		public string SensorDistanceLeftString { get { return "Left: " + Vehicle.SensorDistanceLeft + " cm"; } }
		public string SensorDistanceRightString { get { return "Right: " + Vehicle.SensorDistanceRight + " cm"; } }
		public string BatteryVoltageString { get { return Vehicle.BatteryVoltage + " mV"; } }
		public string BatteryPercentageString { get { return Math.Round(((double)Vehicle.BatteryVoltage / Data.BatteryVoltageMax * 100)).ToString() + " %"; } }
		#endregion

		#region Construction
		public VehicleViewModel()
		{
			ActualPWMSpeed = Data.PWMSpeedDefault;
			ActualPWMHeading = Data.PWMHeadingDefault;
		}
		#endregion		
	}
}
