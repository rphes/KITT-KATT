using System;
using System.ComponentModel;
using System.IO.Ports;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace SerialApp
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		public MainWindow()
		{
			InitializeComponent();
			this.Closing += MainWindow_Closing;
			this.DataContext = Data.serial;
		}

		void MainWindow_Closing(object sender, CancelEventArgs e)
		{
			Data.matlab.Dispose();
		}

		#region Communication controls
		private void ComboBox_COM_DropDownOpened(object sender, System.EventArgs e)
		{
			string[] ports = SerialPort.GetPortNames();
			ComboBox_COM.Items.Clear();

			foreach (string port in ports)
			{
				ComboBox_COM.Items.Add(port);
			}
		}

		private void Button_Connect_Click(object sender, RoutedEventArgs e)
		{
			string port = Convert.ToString(ComboBox_COM.SelectedValue);

			if (!Data.serial.SerialPort.IsOpen)
			{
				if (!String.IsNullOrEmpty(port) && port.Substring(0, 3) == "COM")
				{
					Data.serial.SerialPort.PortName = port;
					if (Data.serial.OpenPort() != 0)
					{
						MessageBox.Show(Data.serial.LastError, "Could not open port", MessageBoxButton.OK, MessageBoxImage.Error);
					}
					else
					{
						Button_Connect.Content = "Disconnect";
						ComboBox_COM.IsEnabled = false;
					}
				}
				else
				{
					MessageBox.Show("Please select a COM-port", "No port selected", MessageBoxButton.OK, MessageBoxImage.Error);
				}
			}
			else
			{
				Data.serial.SerialPort.Close();
				Button_Connect.Content = "Connect";
				ComboBox_COM.IsEnabled = true;
			}
		}
		#endregion

		private void TextBox_Log_TextChanged(object sender, System.Windows.Controls.TextChangedEventArgs e)
		{
			TextBox b = (TextBox)(e.Source);
			b.ScrollToEnd();
		}

		private void TextBox_Command_KeyDown(object sender, System.Windows.Input.KeyEventArgs e)
		{
			TextBox b = (TextBox)(e.Source);

			if (e.Key == Key.Enter)
			{
				Data.serial.SendString(b.Text);
				b.Text = "";
			}
		}

		private void Button_MatlabConnect_Click(object sender, RoutedEventArgs e)
		{
			if (Data.matlab == null)
			{
				Data.matlab = new Matlab();
				Button_MatlabConnect.Content = "Close Matlab";
				Button_StartSerial.IsEnabled = true;
			}
			else
			{
				Data.matlab.Dispose();
				Data.matlab = null;
				Button_MatlabConnect.Content = "Connect to Matlab";
				Button_StartSerial.IsEnabled = false;
			}
		}

		private void Button_StartSerial_Click(object sender, RoutedEventArgs e)
		{
			if (!Data.matlab.SerialPoller.IsEnabled)
			{
				Data.matlab.SerialPoller.Start();
				Button_StartSerial.Content = "Stop serial polling";
			}
			else
			{

				Data.matlab.SerialPoller.Stop();
				Button_StartSerial.Content = "Start serial polling";
			}
		}
	}
}
