using Overwatch.ViewModel;
using System;
using System.Collections.Generic;
using System.Timers;
using System.Windows.Threading;

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
		public Waypoint CurrentWayPoint 
		{ 
			get 
			{
				if (QueuedWaypoints.Count > 0)
					return QueuedWaypoints[0];
				else
					return null;
			} 
		}

		public bool ObservationEnabled { get; set; }
		public bool ControlEnabled { get; set; }
		public string Mode { get; set; }

		private Timer simulationTimer;
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
			{
				Matlab.Hide();
				if (simulationTimer.Enabled)
					simulationTimer.Stop();
			}

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
				if (Mode == "Simulation")
				{
					Matlab.PutVariable("makeSimulator", 1);
					Matlab.PutVariable("makeWrapper", 0);
				}
				else if (Mode == "Reality")
				{
					Matlab.PutVariable("makeWrapper", 1);
					Matlab.PutVariable("makeSimulator", 0);
				}

				Matlab.Instance.Feval("init", 0, out o);
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.ToString());
			}

			if (Mode == "Simulation")
			{
				simulationTimer = new Timer();
				simulationTimer.Interval = 125;
				simulationTimer.Elapsed += simulationTimer_Elapsed;
				simulationTimer.Start();
			}
		}

		public double[] IterateMatlabScripts()
		{
			if (!ObservationEnabled) return null;
			if (CurrentWayPoint == null)
			{
				Data.MainViewModel.AutoControlViewModel.Toggle();
				return null;
			}

			// Push relevant newly received data to MATLAB
			if (Mode == "Reality")
			{
				Matlab.PutVariable("sensor_l", "global", Vehicle.SensorDistanceLeft);
				Matlab.PutVariable("sensor_r", "global", Vehicle.SensorDistanceRight);
			}
			Matlab.PutVariable("battery", "global", Vehicle.BatteryVoltage);
			Matlab.PutVariable("waypoint", "global", CurrentWayPoint != null ? new double[] { CurrentWayPoint.X * Data.FieldSize, CurrentWayPoint.Y * Data.FieldSize } : new double[]{});

			// Run the iterative function in MATLAB
			try
			{
				object success = null;
				if (Mode == "Reality")
					Matlab.Instance.Feval("loop", 0, out success);
				else if (Mode == "Simulation")
					Matlab.Instance.Feval("loop_sim", 0, out success);
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.ToString());
			}

			// Get relevant newly calculated data from MATLAB
			object o = Matlab.GetVariable("loc_x");
			VehicleViewModel.X = (double)Matlab.GetVariable("loc_x", "global") / Data.FieldSize;
			VehicleViewModel.Y = (double)Matlab.GetVariable("loc_y", "global") / Data.FieldSize;
			VehicleViewModel.Angle = (double)Matlab.GetVariable("angle", "global") / Math.PI * 180;
			Vehicle.Velocity = (double)Matlab.GetVariable("speed", "global");
			double PWMSteer = (double)Matlab.GetVariable("pwm_steer", "global");
			double PWMDrive = (double)Matlab.GetVariable("pwm_drive", "global");

			// Check if we should advance to the next waypoint
			double d = Math.Sqrt(Math.Pow(VehicleViewModel.X - CurrentWayPoint.X, 2) + Math.Pow(VehicleViewModel.Y - CurrentWayPoint.Y, 2));
			if (d * Data.FieldSize < 0.2)
				Data.MainViewModel.VisualisationViewModel.FinishWaypointViewModel();

			return new double[] { PWMSteer, PWMDrive };
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

		/// <summary>
		/// Mark a waypoint as finished by moving it from the queue to the visited list.
		/// </summary>
		/// <param name="w">The waypoint to mark as finished.</param>
		public void FinishWaypoint(Waypoint w)
		{
			QueuedWaypoints.Remove(w);
			VisitedWaypoints.Add(w);
		}

		/// <summary>
		/// Mark a waypoint as no longer finished by moving it from the visited list back into the queue.
		/// </summary>
		/// <param name="w">The waypoint to mark as no longer finished.</param>
		public void UnFinishWaypoint(Waypoint w)
		{
			VisitedWaypoints.Remove(w);
			QueuedWaypoints.Add(w);
		}

		/// <summary>
		/// Swap two waypoints in the queue.
		/// </summary>
		/// <param name="index1">The index of the first waypoint two sap.</param>
		/// <param name="index2">The index of the second waypoint to swap.</param>
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
			double[] PWM = IterateMatlabScripts();
	
			// Control KITT and request new status
			if (ControlEnabled)
				Data.MainViewModel.CommunicationViewModel.Communication.DoDrive((int)PWM[0], (int)PWM[1]);

			Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();
		}

		void simulationTimer_Elapsed(object sender, EventArgs e)
		{
			IterateMatlabScripts();
		}
		#endregion
	}
}
