using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Input;

namespace Overwatch.ViewModel
{
	public class AutoControlViewModel : ObservableObject
	{
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

		#region Commands
		#region Connect
		void ToggleAutoControlExecute()
		{
			Enabled = !Enabled;
			if (Enabled)
				Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();

			RaisePropertyChanged("AutoControlButtonString");
		}

		bool CanToggleAutoControlExecute()
		{
			return Data.MainViewModel.CommunicationViewModel.Communication.SerialPort.IsOpen;
		}

		public ICommand ToggleAutoControl { get { return new RelayCommand(ToggleAutoControlExecute, CanToggleAutoControlExecute); } }
		#endregion
		#endregion
	}
}
