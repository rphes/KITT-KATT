using System;
using System.Windows.Input;
using System.Windows.Threading;

namespace KITT_Drive_dotNET.ViewModel
{
	public class ControlViewModel : ObservableObject
	{
		#region Data members
		//Model
		private Control _control = new Control();

		public Control Control
		{
			get { return _control; }
			set { _control = value; }
		}
			
		//Increment values
		const double speedIncrement = 1;
		const double speedIncrementInitial = 6;
		const double headingIncrement = 5;
		const double headingIncrementInitial = 20;
		//Decrement multiplier
		const double decrementMultiplier = 0.9;

		public bool CanControl
		{
			get
			{
				if (Data.MainViewModel.CommunicationViewModel.Communication.SerialPort.IsOpen && Data.MainViewModel.AutoControlViewModel.Status != AutoControlStatus.Running)
					return true;
				else
					return false;
			}
		}

		public double Speed
		{
			get { return Control.Speed; }
			set
			{
				Control.Speed = Data.Clamp(value, Data.SpeedMin, Data.SpeedMax);
				RaisePropertyChanged("Speed");

				int intspeed = (int)Math.Round(Speed) + Data.PWMOffset;
				if (intspeed != PWMSpeed)
					PWMSpeed = intspeed;
			}
		}

		public int PWMSpeed
		{
			get { return Control.PWMSpeed; }
			set
			{
				Control.PWMSpeed = value;
				RaisePropertyChanged("PWMSpeed");
				RaisePropertyChanged("SpeedString");
			}
		}

		public string SpeedString { get { return "Speed: " + (PWMSpeed - Data.PWMOffset); } }

		public double Heading
		{
			get { return Control.Heading; }
			set
			{
				Control.Heading = Data.Clamp(value, Data.HeadingMin, Data.HeadingMax);
				RaisePropertyChanged("Heading");

				int intheading = (int)Math.Round(-Control.Heading) + Data.PWMOffset; //negate for reverse steering
				if (intheading != PWMHeading)
					PWMHeading = intheading;
			}
		}

		public int PWMHeading
		{
			get { return Control.PWMHeading; }
			set
			{
				Control.PWMHeading = value;
				RaisePropertyChanged("PWMHeading");
				RaisePropertyChanged("HeadingString");
			}
		}

		public string HeadingString { get { return "Heading: " + (-PWMHeading + Data.PWMOffset); } } //undo reverse steering compensation

		public DispatcherTimer speedDecrementTimer;
		public DispatcherTimer headingDecrementTimer;
		#endregion

		#region Construction
		public ControlViewModel()
		{
			Speed = Data.SpeedDefault;
			Heading = Data.HeadingDefault;
			speedDecrementTimer = new DispatcherTimer();
			speedDecrementTimer.Tick += speedDecrementTimer_Tick;
			headingDecrementTimer = new DispatcherTimer();
			headingDecrementTimer.Tick += headingDecrementTimer_Tick;
			speedDecrementTimer.Interval = headingDecrementTimer.Interval = new TimeSpan(0, 0, 0, 0, 10);
		}
		#endregion

		#region UI Helpers
		private void speedDecrementTimer_Tick(object sender, EventArgs e)
		{
			if (Speed != Data.SpeedDefault)
			{
				double delta = Data.SpeedDefault - Speed;
				Speed = Speed * decrementMultiplier;

				Speed = Data.Snap(Speed, Data.SpeedDefault, -speedIncrement, speedIncrement);
			}

			if (Speed == Data.SpeedDefault)
				speedDecrementTimer.Stop();
		}

		private void headingDecrementTimer_Tick(object sender, EventArgs e)
		{
			if (Heading != Data.HeadingDefault)
			{
				double delta = Data.HeadingDefault - Heading;
				Heading = Heading * decrementMultiplier;

				Heading = Data.Snap(Heading, Data.HeadingDefault, -headingIncrement, headingIncrement);
			}

			if (Heading == Data.HeadingDefault)
				headingDecrementTimer.Stop();
		}
		#endregion
		
		#region Control methods
		public void Throttle(double increment)
		{
			Speed += increment;
		}

		public void Throttle(Direction d)
		{
			Throttle(d, false);
		}

		public void Throttle(Direction d, bool initial)
		{
			double increment = 0;

			if (initial)
			{
				if (d == Direction.up)
					increment = speedIncrementInitial;
				else if (d == Direction.down)
					increment = -speedIncrementInitial;
			}
			else
			{
				if (d == Direction.up)
					increment = speedIncrement;
				else if (d == Direction.down)
					increment = -speedIncrement;
			}

			Throttle(increment);
		}

		public void Steer(double increment)
		{
			Heading += increment;
		}

		public void Steer(Direction d)
		{
			Steer(d, false);
		}

		public void Steer(Direction d, bool initial)
		{
			double increment = 0;

			if (Heading == Data.HeadingDefault && initial)
			{
				if (d == Direction.right)
					increment = headingIncrementInitial;
				else if (d == Direction.left)
					increment = -headingIncrementInitial;
			}
			else
			{
				if (d == Direction.right)
					increment = headingIncrement;
				else if (d == Direction.left)
					increment = -headingIncrement;
			}

			Steer(increment);
		}

		public void Stop()
		{
			Heading = Data.HeadingDefault;
			Speed = Data.SpeedDefault;

			if (Data.MainViewModel.AutoControlViewModel.Status == AutoControlStatus.Running)
				Data.MainViewModel.AutoControlViewModel.Stop();
		}
		#endregion

		#region Commands
		bool CanControlExecute()
		{
			return CanControl;
		}
		bool CanStopExecute()
		{
			if (Data.MainViewModel.CommunicationViewModel.Communication.SerialPort.IsOpen)
				return true;
			else
				return false;
		}

		void ThrottleUpExecute()
		{
			Throttle(Direction.up, true);
		}
		void ThrottleDownExecute()
		{
			Throttle(Direction.down, true);
		}
		void SteerLeftExecute()
		{
			Steer(Direction.left, true);
		}
		void SteerRightExecute()
		{
			Steer(Direction.right, true);
		}
		void GetStatusExecute()
		{
			Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();
		}
		void StopExecute()
		{
			Stop();
		}

		public ICommand ThrottleUp { get { return new RelayCommand(ThrottleUpExecute, CanControlExecute); } }
		public ICommand ThrottleDown { get { return new RelayCommand(ThrottleDownExecute, CanControlExecute); } }
		public ICommand SteerLeft { get { return new RelayCommand(SteerLeftExecute, CanControlExecute); } }
		public ICommand SteerRight { get { return new RelayCommand(SteerRightExecute, CanControlExecute); } }
		public ICommand GetStatus { get { return new RelayCommand(GetStatusExecute, CanControlExecute); } }
		public ICommand DoStop { get { return new RelayCommand(StopExecute, CanStopExecute); } }

		#endregion
	}
}
