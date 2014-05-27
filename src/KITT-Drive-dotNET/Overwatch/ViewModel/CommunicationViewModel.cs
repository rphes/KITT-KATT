using System;
using System.IO.Ports;
using System.Windows;
using System.Windows.Input;

namespace Overwatch.ViewModel
{
	public class CommunicationViewModel : ObservableObject
	{
		#region Properties
		private Communication _communication = new Communication();

		public Communication Communication
		{
			get { return _communication; }
			set { _communication = value; }
		}

		public string[] SerialPorts { get { return SerialPort.GetPortNames(); } }
		public bool CanSelectSerialPort
		{
			get
			{
				if (Communication.SerialPort.IsOpen)
					return false;
				else
					return true;
			}
		}

		public object SelectedSerialPort { get; set; }
		public string ConnectButtonString
		{
			get
			{
				if (Communication.SerialPort.IsOpen)
					return "Disconnect";
				else
					return "Connect";
			}
		}

		public string PingString {
			get 
			{
				if (Communication.SerialPort.IsOpen)
					return "Last ping: " + Math.Round(Communication.Ping.TotalMilliseconds) + " ms";
				else
					return "Not connected";
			} 
		}

		public string BeaconButtonString
		{
			get
			{
				if (Data.MainViewModel.VehicleViewModel.Vehicle.BeaconIsEnabled)
					return "Disable beacon";
				else
					return "Enable beacon";
			}
		}
		#endregion


		#region Construction
		public CommunicationViewModel()
		{
			Communication.StatusReceived += Communication_StatusReceived;
		}

		private void Communication_StatusReceived(object sender, EventArgs e)
		{
			RaisePropertyChanged("PingString");
			RaisePropertyChanged("BeaconButtonString");
		}
		#endregion

		#region Commands
		#region Connect
		void ConnectExecute()
		{
			if (!Communication.SerialPort.IsOpen)
			{
				//Connect
				Communication.SerialPort.PortName = (string)SelectedSerialPort;

				if (Communication.OpenPort() != 0)
					MessageBox.Show(Communication.LastError, "Could not open port", MessageBoxButton.OK, MessageBoxImage.Error);
				else
					Communication.RequestStatus(); //Request initial status
			}
			else
			{
				//Disconnect
				Communication.SerialPort.Close();
				RaisePropertyChanged("SerialPorts");
			}

			RaisePropertyChanged("ConnectButtonString");
			RaisePropertyChanged("CanSelectSerialPort");
			RaisePropertyChanged("PingString");
		}

		bool CanConnectExecute()
		{
			string port = (string)SelectedSerialPort;
			if ((!Communication.SerialPort.IsOpen && !String.IsNullOrEmpty(port) && port.Substring(0, 3) == "COM") || Communication.SerialPort.IsOpen)
				return true;

			return false;
		}

		public ICommand Connect { get { return new RelayCommand(ConnectExecute, CanConnectExecute); } }
		#endregion
		#region Toggle beacon
		void ToggleBeaconExecute()
		{
			Communication.ToggleAudio();
		}

		bool CanToggleBeaconExecute()
		{
			if (Communication.SerialPort.IsOpen)
				return true;

			return false;
		}

		public ICommand ToggleBeacon { get { return new RelayCommand(ToggleBeaconExecute, CanToggleBeaconExecute); } }
		#endregion
		#endregion
	}
}
