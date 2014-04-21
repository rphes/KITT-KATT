using System;
using System.IO.Ports;
using System.Windows;
using System.Windows.Controls.Primitives;
using System.Windows.Input;
using System.Windows.Threading;

namespace KITT_Drive_dotNET
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		#region Data members
		private DispatcherTimer throttleTimer, steerTimer;
		private Key throttleTimerKey, steerTimerKey;
		#endregion

		#region Construction
		public MainWindow()
		{
			InitializeComponent();
			this.DataContext = Data.MainViewModel;

			Data.MainViewModel.ControlViewModel.PropertyChanged += Drive_PropertyChanged;
			this.Closing += MainWindow_Closing;

			throttleTimer = new DispatcherTimer();
			throttleTimer.Tick += ThrottleTimer_Tick;
			steerTimer = new DispatcherTimer();
			steerTimer.Tick += SteerTimer_Tick;
			throttleTimer.Interval = steerTimer.Interval = new TimeSpan(0, 0, 0, 0, 10);
		}

		private void MainWindow_Closing(object sender, System.ComponentModel.CancelEventArgs e)
		{
			Data.MainViewModel.CommunicationViewModel.Communication.Dispose();
		}
		#endregion

		#region Command transmission
		private void Drive_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
		{
			if (Data.MainViewModel.CommunicationViewModel.Communication != null && Data.MainViewModel.CommunicationViewModel.Communication.SerialPort.IsOpen && (e.PropertyName == "SpeedString" || e.PropertyName == "HeadingString"))
			{
				Data.MainViewModel.CommunicationViewModel.Communication.DoDrive(Data.MainViewModel.ControlViewModel.PWMHeading, Data.MainViewModel.ControlViewModel.PWMSpeed);
			}
		}
		#endregion

		#region Key vehicle controls
		private void Window_KeyDown(object sender, System.Windows.Input.KeyEventArgs e)
		{
			if (Data.MainViewModel.CommunicationViewModel.Communication == null || !Data.MainViewModel.CommunicationViewModel.Communication.SerialPort.IsOpen || e.IsRepeat) return;

			Key key = e.Key;

			if (key == Key.W || key == Key.S)
			{
				if (throttleTimerKey != Key.None)
					return;

				if (key == Key.W)
					Data.MainViewModel.ControlViewModel.Throttle(Direction.up, true);
				else if (key == Key.S)
					Data.MainViewModel.ControlViewModel.Throttle(Direction.down, true);

				throttleTimer.Start();
				Data.MainViewModel.ControlViewModel.speedDecrementTimer.Stop();
				throttleTimerKey = key;
			}

			if (key == Key.A || key == Key.D)
			{
				if (steerTimerKey != Key.None)
					return;

				if (key == Key.A)
					Data.MainViewModel.ControlViewModel.Steer(Direction.left, true);
				else if (key == Key.D)
					Data.MainViewModel.ControlViewModel.Steer(Direction.right, true);

				steerTimer.Start();
				Data.MainViewModel.ControlViewModel.headingDecrementTimer.Stop();
				steerTimerKey = key;
			}

			if (key == Key.Q)
			{
				Data.MainViewModel.ControlViewModel.Stop();
				Data.MainViewModel.AutoControlViewModel.AutoControl.Stop();
			}
		}

		private void Window_KeyUp(object sender, KeyEventArgs e)
		{
			Key key = e.Key;

			if (Data.MainViewModel.CommunicationViewModel.Communication == null || !Data.MainViewModel.CommunicationViewModel.Communication.SerialPort.IsOpen || !(key == Key.W || key == Key.A || key == Key.S || key == Key.D))
				return;

			if (key == Key.W || key == Key.S)
			{
				throttleTimer.Stop();
				Data.MainViewModel.ControlViewModel.speedDecrementTimer.Start();
				throttleTimerKey = Key.None;
			}
			else if (key == Key.A || key == Key.D)
			{
				steerTimer.Stop();
				Data.MainViewModel.ControlViewModel.headingDecrementTimer.Start();
				steerTimerKey = Key.None;
			}
		}

		private void SteerTimer_Tick(object sender, System.EventArgs e)
		{
			if (steerTimerKey == Key.A)
				Data.MainViewModel.ControlViewModel.Steer(Direction.left, false);
			else if (steerTimerKey == Key.D)
				Data.MainViewModel.ControlViewModel.Steer(Direction.right, false);
		}

		private void ThrottleTimer_Tick(object sender, System.EventArgs e)
		{
			if (throttleTimerKey == Key.W)
				Data.MainViewModel.ControlViewModel.Throttle(Direction.up, false);
			else if (throttleTimerKey == Key.S)
				Data.MainViewModel.ControlViewModel.Throttle(Direction.down, false);
		}
		#endregion

		#region Button vehicle controls
		private void Button_ThrottleUp_Click(object sender, RoutedEventArgs e)
		{
			Data.MainViewModel.ControlViewModel.Throttle(Direction.up, true);
		}

		private void Button_ThrottleDown_Click(object sender, RoutedEventArgs e)
		{
            Data.MainViewModel.ControlViewModel.Throttle(Direction.down, true);
		}

		private void Button_SteerLeft_Click(object sender, RoutedEventArgs e)
		{
            Data.MainViewModel.ControlViewModel.Steer(Direction.left, true);
		}

		private void Button_SteerRight_Click(object sender, RoutedEventArgs e)
		{
            Data.MainViewModel.ControlViewModel.Steer(Direction.right, true);
		}


		private void Button_Status_Click(object sender, RoutedEventArgs e)
		{
			Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();
		}

		private void Button_STOP_Click(object sender, RoutedEventArgs e)
		{
			Data.MainViewModel.ControlViewModel.Speed = Data.SpeedDefault;
			Data.MainViewModel.ControlViewModel.Heading = Data.HeadingDefault;
		}
		#endregion
	}
}
