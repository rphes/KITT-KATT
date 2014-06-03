using Overwatch.Tools;
using System;

namespace Overwatch.ViewModel
{
	/// <summary>
	/// Provides binding data for all vehicle-status related gui-elements, based on an instance of the Vehicle class
	/// </summary>
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

		//Position
		public double X
		{
			get { return Vehicle.X; }
			set 
			{ 
				Vehicle.X = value; //from 0 to 1
				RaisePropertyChanged("X");
			} 
		}
		public double Y
		{
			get { return Vehicle.Y; }
			set
			{
				Vehicle.Y = value;
				RaisePropertyChanged("Y");
			} //from 0 to 1
		}
		public double Angle
		{
			get { return Vehicle.Angle; }
			set
			{
				Vehicle.Angle = value;
				RaisePropertyChanged("Angle");
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
		public string BatteryPercentageString { get { return Math.Round(((double)Vehicle.BatteryVoltage / Vehicle.BatteryVoltageMax * 100)).ToString() + " %"; } }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the VehicleViewModel class
		/// </summary>
		public VehicleViewModel()
		{
			ActualPWMSpeed = Vehicle.PWMSpeedDefault;
			ActualPWMHeading = Vehicle.PWMHeadingDefault;
		}
		#endregion		
	}
}
