using Overwatch.Tools;
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

		public bool Enabled
		{
			get { return AutoControl.Enabled; }
			set { AutoControl.Enabled = value; }
		}
		
		public string AutoControlButtonString
		{
			get
			{
				if (Enabled)
					return "Disable AutoControl";
				else
					return "Enable AutoControl";
			}
		}

		public string[] PlaceableObjects { get { return new string[] { "Waypoint", "Charger" }; } }

		public string SelectedObject { get; set; }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the AutoControlViewModel class.
		/// </summary>
		public AutoControlViewModel()
		{
			SelectedObject = "Waypoint";
		}
		#endregion

		#region Methods
		public void Toggle()
		{
			// Toggle autonomous control and send initial status request if enabled
			if (AutoControl.Toggle())
				Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();

			RaisePropertyChanged("AutoControlButtonString");
		}
		#endregion

		#region Commands
		#region Toggle AutoControl
		/// <summary>
		/// Toggles autonomous vehicle control.
		/// </summary>
		void ToggleAutoControlExecute()
		{
			Toggle();
		}

		bool CanToggleAutoControlExecute()
		{
			if (!AutoControl.Matlab.Visible && Enabled)
				Toggle();

			return Data.MainViewModel.CommunicationViewModel.Communication.SerialPort.IsOpen &&
				AutoControl.Matlab.Running &&
				Data.SrcDirectory != null;
		}

		public ICommand ToggleAutoControl { get { return new RelayCommand(ToggleAutoControlExecute, CanToggleAutoControlExecute); } }
		#endregion
		#endregion
	}
}
