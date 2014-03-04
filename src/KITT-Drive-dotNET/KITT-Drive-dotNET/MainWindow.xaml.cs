using System.Windows;
using MLApp;
using System.IO.Ports;
using System;
using System.Windows.Input;

namespace KITT_Drive_dotNET
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		Drive Drive = new Drive();
		SerialInterface KITTCom;

		public MainWindow()
		{
			InitializeComponent();
			Drive.PropertyChanged += Drive_PropertyChanged;
		}

		private void Drive_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
		{
			if (KITTCom != null && KITTCom.IsOpen)
			{
				KITTCom.DoDrive(Drive.Dir, Drive.Speed);
				System.Diagnostics.Debug.Print(Drive.Speed.ToString() + ' ' + Drive.Dir.ToString());
			}
		}

		private void ComboBox_COM_DropDownOpened(object sender, System.EventArgs e)
		{
			string[] ports = SerialPort.GetPortNames();

			foreach (string port in ports)
			{
				ComboBox_COM.Items.Add(port);
			}
		}

		private void Button_Connect_Click(object sender, RoutedEventArgs e)
		{
			string port = ((string)ComboBox_COM.SelectedValue);

			if (port.Substring(0, 3) == "COM")
			{
				KITTCom = new SerialInterface(port);
				if (KITTCom.OpenPort() != 0)
				{
					MessageBox.Show(KITTCom.lastError, "Could not open port", MessageBoxButton.OK, MessageBoxImage.Error);
				}
				else
				{
					ComboBox_COM.IsEnabled = false;
					Button_Connect.IsEnabled = false;
				}
			}
			else
			{
				MessageBox.Show("Please select a COM-port", "No port selected", MessageBoxButton.OK, MessageBoxImage.Error);
			}
		}

		private void Window_KeyDown(object sender, System.Windows.Input.KeyEventArgs e)
		{
			Key key = e.Key;

			switch (key)
			{
				case Key.W:
					Drive.Throttle(Direction.up);
					break;
				case Key.A:
					Drive.Steer(Direction.left);
					break;
				case Key.S:
					Drive.Throttle(Direction.down);
					break;
				case Key.D:
					Drive.Steer(Direction.right);
					break;	
				default:
					break;
			}
		}

		private void Button_ThrottleUp_Click(object sender, RoutedEventArgs e)
		{
			Drive.Throttle(Direction.up);
		}

		private void Button_ThrottleDown_Click(object sender, RoutedEventArgs e)
		{
			Drive.Throttle(Direction.down);
		}

		private void Button_SteerLeft_Click(object sender, RoutedEventArgs e)
		{
			Drive.Steer(Direction.left);
		}

		private void Button_SteerRight_Click(object sender, RoutedEventArgs e)
		{
			Drive.Steer(Direction.right);
		}
	}
}
