﻿using Overwatch.Tools;
using System.Windows.Input;

namespace Overwatch.ViewModel
{
	/// <summary>
	/// Provides binding data and commands for all autonomous control related gui-elements, based on an instance of the AutoControl class.
	/// </summary>
	public class AutoControlViewModel : ObservableObject
	{
		#region Data members
		private AutoControl _autocontrol = new AutoControl();

		public AutoControl AutoControl
		{
			get { return _autocontrol; }
			set { _autocontrol = value; }
		}

		public bool ObservationEnabled
		{
			get { return AutoControl.ObservationEnabled; }
		}

		public string ObservationButtonString
		{
			get
			{
				if (ObservationEnabled)
					return "Disable Observation";
				else
					return "Enable Observation";
			}
		}

		public bool ControlEnabled
		{
			get { return AutoControl.ControlEnabled; }
		}

		public string ControlButtonString
		{
			get
			{
				if (ControlEnabled)
					return "Disable Control";
				else
					return "Enable Control";
			}
		}

		public string[] Modes { get { return new string[] { "Reality", "Simulation" }; } }
		public string SelectedMode
		{
			get { return AutoControl.Mode; }
			set { AutoControl.Mode = value; }
		}
		public bool CanSelectMode { get { return !ControlEnabled; } }

		public string[] PlaceableObjects { get { return new string[] { "Waypoint" }; } }
		public string SelectedObject { get; set; }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the AutoControlViewModel class.
		/// </summary>
		public AutoControlViewModel()
		{
			SelectedMode = "Reality";
			SelectedObject = "Waypoint";
		}
		#endregion

		#region Methods
		/// <summary>
		/// Toggle both observation and control at the same time.
		/// </summary>
		public void Toggle()
		{
			if (CanToggleObservationExecute())
				ToggleObservationExecute();
			if (CanToggleControlExecute())
				ToggleControlExecute();
		}
		#endregion

		#region Commands
		#region Toggle Observation
		/// <summary>
		/// Toggles vehicle observation.
		/// </summary>
		void ToggleObservationExecute()
		{
			if (AutoControl.ToggleObservation())
				Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();

			RaisePropertyChanged("ObservationButtonString");
		}

		bool CanToggleObservationExecute()
		{
			if (!AutoControl.Matlab.Visible && ObservationEnabled)
				AutoControl.ToggleObservation();

			RaisePropertyChanged("ObservationButtonString");

			return (Data.MainViewModel.CommunicationViewModel.Communication.SerialPort.IsOpen || SelectedMode == "Simulation") &&
				AutoControl.Matlab.Running &&
				Data.SrcDirectory != null &&
				!(AutoControl.QueuedWaypoints.Count == 0 && !AutoControl.ObservationEnabled);
		}

		public ICommand ToggleObservation { get { return new RelayCommand(ToggleObservationExecute, CanToggleObservationExecute); } }
		#endregion

		#region Toggle Control
		/// <summary>
		/// Toggles autonomous vehicle control.
		/// </summary>
		void ToggleControlExecute()
		{
			// Toggle autonomous control and send initial status request if enabled
			AutoControl.ToggleControl();
			RaisePropertyChanged("ControlButtonString");
			RaisePropertyChanged("CanSelectMode");
		}

		bool CanToggleControlExecute()
		{
			if ((!AutoControl.Matlab.Visible || !ObservationEnabled) && ObservationEnabled && AutoControl.Mode == "Reality")
			{
				AutoControl.ToggleControl();
				RaisePropertyChanged("ControlButtonString");
				RaisePropertyChanged("CanSelectMode");
			}

			return ObservationEnabled;
		}

		public ICommand ToggleControl { get { return new RelayCommand(ToggleControlExecute, CanToggleControlExecute); } }
		#endregion
		#endregion
	}
}