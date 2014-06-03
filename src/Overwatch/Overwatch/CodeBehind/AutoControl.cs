using System;
using System.Collections.Generic;
using System.Linq;
using Overwatch.ViewModel;

namespace Overwatch
{
	/// <summary>
	/// Holds all required data and methods to enable autonomous control of the vehicle via MATLAB.
	/// Also handles the connection with MATLAB for the exchange of data.
	/// </summary>
	public class AutoControl
	{
		#region Data members
		public Matlab Matlab { get; set; }
		public Vehicle Vehicle { get { return Data.MainViewModel.VehicleViewModel.Vehicle; } }
		public ViewModel.VehicleViewModel VehicleViewModel { get { return Data.MainViewModel.VehicleViewModel; } }
		public List<Waypoint> Waypoints { get; protected set; }

		public bool Enabled { get; set; }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the AutoControl class.
		/// </summary>
		public AutoControl()
		{
			// Disable by default
			Enabled = false;
			// Initialise MATLAB
			Matlab = new Matlab();
			Matlab.Hide();
			// Initialise some other stuff
			Waypoints = new List<Waypoint>();
			// Subscribe to status updates
			Data.MainViewModel.CommunicationViewModel.Communication.StatusReceived += Communication_StatusReceived;
		}
		#endregion

		#region Methods
		/// <summary>
		/// Toggles autonomous control of the vehicle.
		/// </summary>
		/// <returns>True if autocontrol is enabled, false if disabled.</returns>
		public bool Toggle()
		{
			Enabled = !Enabled;

			if (Enabled)
				Matlab.Show();
			else
				Matlab.Hide();

			return Enabled;
		}

		/// <summary>
		/// Create a new waypoint at the given location, along with a corresponding ViewModel and notify MATLAB.
		/// </summary>
		/// <param name="x">The position of the waypoint on the X-axis.</param>
		/// <param name="y">The position of the waypoint on the Y-axis.</param>
		/// <returns>The newly created WaypointViewModel.</returns>
		public WaypointViewModel AddWaypoint(double x, double y)
		{
			// Create a new ViewModel
			WaypointViewModel wvm = new WaypointViewModel(x, y);
			// Add its Waypoint to the list
			Waypoints.Add(wvm.Waypoint);

			// Push new list to MATLAB
			pushWaypointsToMatlab();

			// Return the ViewModel
			return wvm;
		}

		/// <summary>
		/// Remove the given waypoint.
		/// </summary>
		/// <param name="w">The waypoint to remove.</param>
		public void RemoveWaypoint(WaypointViewModel w)
		{
			// Remove the waypoint from the list
			Waypoints.Remove(w.Waypoint);

			// Push new list to MATLAB
			pushWaypointsToMatlab();
		}

		/// <summary>
		/// Push a m*2 double containing all waypoint locations to MATLAB.
		/// </summary>
		private void pushWaypointsToMatlab()
		{
			double[,] w = new double[2, Waypoints.Count];
			for (int i = 0; i < Waypoints.Count(); i++)
			{
				w[0, i] = Waypoints[i].X;
				w[1, i] = Waypoints[i].Y;
			}
			Matlab.PutVariable("waypoints", w);
		}
		#endregion

		#region Event handling
		/// <summary>
		/// Performs the required actions whenever a new status update is received from the vehicle.
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
