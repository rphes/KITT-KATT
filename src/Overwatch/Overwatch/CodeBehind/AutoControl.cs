using Overwatch.ViewModel;
using System;
using System.Collections.Generic;
using System.Linq;

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
		public List<Waypoint> QueuedWaypoints { get; protected set; }
		public List<Waypoint> VisitedWaypoints { get; protected set; }
		public Waypoint CurrentWayPoint { get { return QueuedWaypoints[0]; } }

		public bool ObservationEnabled { get; set; }
		public bool ControlEnabled { get; set; }
		public string Mode { get; set; }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the AutoControl class.
		/// </summary>
		public AutoControl()
		{
			// Disable by default
			ObservationEnabled = false;
			// Initialise MATLAB
			Matlab = new Matlab();
			Matlab.Hide();
			// Initialise some other stuff
			QueuedWaypoints = new List<Waypoint>();
			VisitedWaypoints = new List<Waypoint>();
			// Subscribe to status updates
			Data.MainViewModel.CommunicationViewModel.Communication.StatusReceived += Communication_StatusReceived;
		}
		#endregion

		#region Methods
		/// <summary>
		/// Toggles observation of the vehicle.
		/// </summary>
		/// <returns>True if observation is enabled, false if disabled.</returns>
		public bool ToggleObservation()
		{
			// Flip the switch
			ObservationEnabled = !ObservationEnabled;

			// Hide or show MATLAB
			if (ObservationEnabled)
			{
				Matlab.Show();
				InitMatlabScripts();
			}
			else
				Matlab.Hide();

			return ObservationEnabled;
		}

		/// <summary>
		/// Toggles autonomous control of the vehicle.
		/// </summary>
		/// <returns>True if autocontrol is enabled, false if disabled.</returns>
		public void ToggleControl()
		{
			// Flip the switch
			ControlEnabled = !ControlEnabled;
		}

		/// <summary>
		/// Initialise MATLAB to the correct directory and run the initialisation script.
		/// </summary>
		public void InitMatlabScripts()
		{
			object o;

			// Get scripts location and try to change MATLAB's directory to it
			string loc = Data.SrcDirectory + "\\Overwatch-MATLAB";

			try
			{
				Matlab.Instance.Feval("cd", 0, out o, loc);
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.ToString());
			}

			o = null; // Has to be reset for some reason

			// Run the init.m script
			try
			{		
				Matlab.Instance.Feval("init", 0, out o);
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.ToString());
			}

			// Try to start simulation
			try
			{
				Matlab.Instance.Feval("simulate", 0, out o);
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.ToString());
			}
		}

		/// <summary>
		/// Create a new waypoint at the given location, along with a corresponding ViewModel and notify MATLAB.
		/// </summary>
		/// <param name="x">The position of the waypoint on the X-axis.</param>
		/// <param name="y">The position of the waypoint on the Y-axis.</param>
		/// <returns>The newly created WaypointViewModel.</returns>
		public void AddWaypoint(Waypoint w)
		{
			// Add Waypoint to the list
			QueuedWaypoints.Add(w);
		}

		/// <summary>
		/// Remove the given waypoint.
		/// </summary>
		/// <param name="w">The waypoint to remove.</param>
		public void RemoveWaypoint(Waypoint w)
		{
			// Remove the waypoint from the correct list
			if (!w.Visited)
				QueuedWaypoints.Remove(w);
			else
				VisitedWaypoints.Remove(w);
		}

		public void FinishWaypoint(Waypoint w)
		{
			QueuedWaypoints.Remove(w);
			VisitedWaypoints.Add(w);
		}

		public void UnFinishWaypoint(Waypoint w)
		{
			VisitedWaypoints.Remove(w);
			QueuedWaypoints.Add(w);
		}

		public void SwapWaypoints(int index1, int index2)
		{
			Waypoint tmp = QueuedWaypoints[index1];
			QueuedWaypoints[index1] = QueuedWaypoints[index2];
			QueuedWaypoints[index2] = tmp;
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
			if (!ObservationEnabled) return;

			// Push relevant newly received data to MATLAB
			Matlab.PutVariable("sensor_l", Vehicle.SensorDistanceLeft);
			Matlab.PutVariable("sensor_r", Vehicle.SensorDistanceRight);
			Matlab.PutVariable("battery", Vehicle.BatteryVoltage);
			Matlab.PutVariable("waypoint", new double[] { CurrentWayPoint.X, CurrentWayPoint.Y });
		
			if (Mode == "Reality")
			{
				// Run the iterative function in MATLAB
				try
				{
					object success = null;
					Matlab.Instance.Feval("loop", 1, out success);
				}
				catch (Exception exc)
				{
					System.Diagnostics.Debug.WriteLine(exc.ToString());
				}
			}

			// Get relevant newly calculated data from MATLAB
			VehicleViewModel.X = (double)Matlab.GetVariable("loc_x") / Data.FieldSize;
			VehicleViewModel.Y = (double)Matlab.GetVariable("loc_y") / Data.FieldSize;
			VehicleViewModel.Angle = (double)Matlab.GetVariable("angle");
			Vehicle.Velocity = (double)Matlab.GetVariable("speed");
			double PWMSteer = (double)Matlab.GetVariable("pwm_steer");
			double PWMDrive = (double)Matlab.GetVariable("pwm_drive");
			if (ControlEnabled)
				Data.MainViewModel.CommunicationViewModel.Communication.DoDrive((int)PWMSteer, (int)PWMDrive);

			// Check if we should advance to the next waypoint
			double d = Math.Sqrt(Math.Pow(VehicleViewModel.X - CurrentWayPoint.X, 2) + Math.Pow(VehicleViewModel.Y - CurrentWayPoint.Y, 2));
			if (d * Data.FieldSize < 0.1)
				FinishWaypoint(CurrentWayPoint);

			// Request new status
			Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();
		}
		#endregion
	}
}
