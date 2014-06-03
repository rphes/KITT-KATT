using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Threading;

namespace Overwatch
{
	/// <summary>
	/// Holds all required data and methods to enable autonomous control of the vehicle via MATLAB
	/// </summary>
	public class AutoControl
	{
		#region Data members
		public Matlab Matlab { get; set; }
		public Vehicle Vehicle { get { return Data.MainViewModel.VehicleViewModel.Vehicle; } }
		public ViewModel.VehicleViewModel VehicleViewModel { get { return Data.MainViewModel.VehicleViewModel; } }
		private List<Point> _waypoints = new List<Point>();
		public List<Point> Waypoints
		{
			get { return _waypoints; }
			set
			{
				_waypoints = value;
				Matlab.PutVariable("waypoints", Waypoints.ToArray());
			}
		}

		public bool Enabled { get; set; }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the AutoControl class
		/// </summary>
		public AutoControl()
		{
			Enabled = false;
			Matlab = new Matlab();
			//Subscribe to status updates
			Data.MainViewModel.CommunicationViewModel.Communication.StatusReceived += Communication_StatusReceived;
		}
		#endregion

		#region Methods
		public bool Enable()
		{
			Enabled = !Enabled;
			if (Enabled)
			{
				Matlab.Show();
			}
			else
			{
				Matlab.Hide();
			}
			return Enabled;
		}
		#endregion

		#region Event handling
		/// <summary>
		/// Performs the required actions whenever a new status update is received from the vehicle
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		void Communication_StatusReceived(object sender, EventArgs e)
		{
			if (!Enabled) return;

			// Push relevant newly received data to MATLAB
			Matlab.PutVariable("sensor_l", Vehicle.SensorDistanceLeft);
			Matlab.PutVariable("sensor_r", Vehicle.SensorDistanceRight);
			Matlab.PutVariable("battery", Vehicle.BatteryVoltage);

			// Run the iterative function in MATLAB
			object success = false;			
			try
			{
				Matlab.Instance.Feval("loop", 1, out success);
			}
			catch(Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.ToString());
			}

			// Get relevant newly calculated data from MATLAB
			if ((bool)success)
			{
				VehicleViewModel.X = (double)Matlab.GetVariable("loc_x");
				VehicleViewModel.Y = (double)Matlab.GetVariable("loc_y");
				VehicleViewModel.Angle = (double)Matlab.GetVariable("angle");
				Vehicle.Velocity = (double)Matlab.GetVariable("speed");
				int PWMSteer = (int)Matlab.GetVariable("pwm_steer");
				int PWMDrive = (int)Matlab.GetVariable("pwm_drive");
				Data.MainViewModel.CommunicationViewModel.Communication.DoDrive(PWMSteer, PWMDrive);
			}

			// Request new status
			Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();
		}
		#endregion
	}
}
