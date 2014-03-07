using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Threading;

namespace KITT_Drive_dotNET
{
	public enum Direction
	{
	      up, down, left, right
	}

	public class Control : INotifyPropertyChanged
	{
		#region Data members
		//Default conditions:
		public const int SpeedDefault = 0; //include offset
		public const int HeadingDefault = 0; //include offset
		public const int PWMOffset = 150;
		//Range
		public int SpeedMin { get { return -15; } }
		public int SpeedMax { get { return 15; } }
		public int HeadingMin { get { return -50; } }
		public int HeadingMax { get { return 50; } }
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
				_speed = Clamp(value, SpeedMin, SpeedMax);
				NotifyPropertyChanged("Speed");
			}
		}

		public int PWMSpeed
		{
			get { return (int)Math.Round(_speed + PWMOffset); }
		}

		private double _heading;

		public double Heading
		{
			get { return _heading; }
			set 
			{
				_heading = Clamp(value, HeadingMin, HeadingMax);
				NotifyPropertyChanged("Heading");
			}
		}

		public int PWMHeading
		{
			get { return (int)Math.Round(_heading + PWMOffset); }
		}

		public DispatcherTimer speedDecrementTimer;
		public DispatcherTimer headingDecrementTimer;
		#endregion

		#region Construction
		public Control()
		{
			Speed = SpeedDefault;
			Heading = HeadingDefault;
			speedDecrementTimer = new DispatcherTimer();
			speedDecrementTimer.Tick += new EventHandler(speedDecrementTimer_Tick);
			headingDecrementTimer = new DispatcherTimer();
			headingDecrementTimer.Tick += new EventHandler(headingDecrementTimer_Tick);
			speedDecrementTimer.Interval = headingDecrementTimer.Interval = new TimeSpan(0, 0, 0, 0, 10);
		}
		#endregion

		#region UI Helpers
		private void speedDecrementTimer_Tick(object sender, EventArgs e)
		{
			if (Speed != SpeedDefault)
			{
				double delta = SpeedDefault - Speed;
				Speed = Speed * decrementMultiplier;

				Speed = Snap(Speed, SpeedDefault, -speedIncrement, speedIncrement);
			}

			if (Speed == SpeedDefault)
				speedDecrementTimer.Stop();
		}

		private void headingDecrementTimer_Tick(object sender, EventArgs e)
		{
			if (Heading != HeadingDefault)
			{
				double delta = HeadingDefault - Heading;
				Heading = Heading * decrementMultiplier;

				Heading = Snap(Heading, HeadingDefault, -headingIncrement, headingIncrement);
			}

			if (Heading == HeadingDefault)
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

			if (Heading == HeadingDefault && initial)
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
			Heading = HeadingDefault;
			Speed = SpeedDefault;
		}
		#endregion

		#region Utility methods
		public double Clamp(double value, double min, double max)
		{
			if (value > max)
				return max;
			if (value < min)
				return min;
			return value;
		}

		public double Snap(double value, double snap, double min, double max)
		{
			if (value < max && value > min)
				return snap;
			else
				return value;
		}
		#endregion

		#region Property change event handling
		public event PropertyChangedEventHandler PropertyChanged;

		private void NotifyPropertyChanged([CallerMemberName] String propertyName = "")
		{
			if (PropertyChanged != null)
			{
				PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
			}
		}
		#endregion
	}
}
