using System;
using System.Windows.Threading;

namespace KITT_Drive_dotNET
{
	/// <summary>
	/// Provides methods and properties for controlling KITT, as well as members for the GUI to bind to
	/// </summary>
	public class Control : ObservableObject
	{
		#region Data members
		
		//Increment values
		const double speedIncrement = 1;
		const double speedIncrementInitial = 6;
		const double headingIncrement = 5;
		const double headingIncrementInitial = 20;
		//Decrement multiplier
		const double decrementMultiplier = 0.9;

		private double _speed;

		public double Speed
		{
			get { return _speed; }
			set
			{
				_speed = Data.Clamp(value, Data.SpeedMin, Data.SpeedMax);
				NotifyPropertyChanged("Speed");

				int intspeed = (int)Math.Round(_speed) + Data.PWMOffset;
				if (intspeed != PWMSpeed)
					PWMSpeed = intspeed;
			}
		}

		private int _pwmSpeed;

		public int PWMSpeed
		{
			get { return _pwmSpeed; }
			protected set
			{
				_pwmSpeed = value;
				NotifyPropertyChanged("PWMSpeed");
				NotifyPropertyChanged("SpeedString");
			}
		}

		public string SpeedString { get { return "Speed: " + (PWMSpeed - Data.PWMOffset); } }

		private double _heading;

		public double Heading
		{
			get { return _heading; }
			set
			{
				_heading = Data.Clamp(value, Data.HeadingMin, Data.HeadingMax);
				NotifyPropertyChanged("Heading");

				int intheading = (int)Math.Round(-_heading) + Data.PWMOffset; //negate for reverse steering
				if (intheading != PWMHeading)
					PWMHeading = intheading;
			}
		}

		private int _pwmHeading;

		public int PWMHeading
		{
			get { return _pwmHeading; }
			protected set
			{
				_pwmHeading = value;
				NotifyPropertyChanged("PWMHeading");
				NotifyPropertyChanged("HeadingString");
			}
		}

		public string HeadingString { get { return "Heading: " + (-PWMHeading + Data.PWMOffset); } } //undo reverse steering compensation

		public DispatcherTimer speedDecrementTimer;
		public DispatcherTimer headingDecrementTimer;
		#endregion

		#region Construction
		public Control()
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
		}
		#endregion
	}
}
