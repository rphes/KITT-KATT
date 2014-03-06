using System.Windows;
using MLApp;
using System.IO.Ports;
using System;
using System.Windows.Input;
using System.Windows.Controls.Primitives;

namespace KITT_Drive_dotNET
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		public MainWindow()
		{
			InitializeComponent();
			
			GroupBox_Control.DataContext = Data.Ctr;

			Data.Ctr.PropertyChanged += Drive_PropertyChanged;
		}

		#region Command transmission
		private void Drive_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
		{
			if (Data.Com != null && Data.Com.IsOpen)
			{
				Data.Com.DoDrive(Data.Ctr.Heading, Data.Ctr.Speed);
				System.Diagnostics.Debug.Print(Data.Ctr.Speed.ToString() + ' ' + Data.Ctr.Heading.ToString());
			}
		}
		#endregion

		#region Communication controls
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
				Data.Com = new SerialInterface(port);
				if (Data.Com.OpenPort() != 0)
				{
					MessageBox.Show(Data.Com.lastError, "Could not open port", MessageBoxButton.OK, MessageBoxImage.Error);
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
		#endregion

		#region Key vehicle controls
		private void Window_KeyDown(object sender, System.Windows.Input.KeyEventArgs e)
		{
			if (Data.Com == null || !Data.Com.IsOpen) return;

			Key key = e.Key;
			bool initial = !e.IsRepeat;

			switch (key)
			{
				case Key.W:
					Data.Ctr.Throttle(Direction.up, initial);
					break;
				case Key.A:
					Data.Ctr.Steer(Direction.left, initial);
					break;
				case Key.S:
					Data.Ctr.Throttle(Direction.down, initial);
					break;
				case Key.D:
					Data.Ctr.Steer(Direction.right, initial);
					break;	
				default:
					break;
			}
		}


		private void Window_KeyUp(object sender, KeyEventArgs e)
		{
			if (Data.Com == null || !Data.Com.IsOpen) return;
			//Data.Ctr.DecrementTimer.Start();
		}

		#endregion

		#region Button vehicle controls
		private void Button_ThrottleUp_Click(object sender, RoutedEventArgs e)
		{
			if (Data.Com == null || !Data.Com.IsOpen) return;
			Data.Ctr.Throttle(Direction.up, true);
		}

		private void Button_ThrottleDown_Click(object sender, RoutedEventArgs e)
		{
			if (Data.Com == null || !Data.Com.IsOpen) return;
			Data.Ctr.Throttle(Direction.down, true);
		}

		private void Button_SteerLeft_Click(object sender, RoutedEventArgs e)
		{
			if (Data.Com == null || !Data.Com.IsOpen) return;
			Data.Ctr.Steer(Direction.left, true);
		}

		private void Button_SteerRight_Click(object sender, RoutedEventArgs e)
		{
			if (Data.Com == null || !Data.Com.IsOpen) return;
			Data.Ctr.Steer(Direction.right, true);
		}
		#endregion

		private void Slider_Speed_DragCompleted(object sender, DragCompletedEventArgs e)
		{
			Data.Ctr.Speed = (int)Slider_Speed.Value;
		}

		private void Slider_Heading_DragCompleted(object sender, DragCompletedEventArgs e)
		{
			Data.Ctr.Heading = (int)Slider_Heading.Value;
		}
	}
}
