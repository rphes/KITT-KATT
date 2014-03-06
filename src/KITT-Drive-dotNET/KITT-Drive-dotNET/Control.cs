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
		const int speedIncrement = 2;
		const int speedIncrementInitial = 10;
		const int directionIncrement = 2;
		const int directionIncrementInitial = 10;
		const double decrementMultiplier = 0.001;

		private int _speed;

		public int Speed
		{
			get { return _speed; }
			set
			{
				_speed = Clamp(value, 100, 200);
				NotifyPropertyChanged("Speed");
			}
		}

		private int _heading;

		public int Heading
		{
			get { return _heading; }
			set 
			{
				_heading = Clamp(value, 100, 200);
				NotifyPropertyChanged("Heading");
			}
		}

		public DispatcherTimer DecrementTimer;
		#endregion

		#region Construction
		public Control()
		{
			Speed = 150;
			Heading = 150;
			DecrementTimer = new DispatcherTimer();
			DecrementTimer.Tick += new EventHandler(DecrementTimer_Tick);
			DecrementTimer.Interval = new TimeSpan(0, 0, 0, 0, 20);
		}

		private void DecrementTimer_Tick(object sender, EventArgs e)
		{
			//Broken
			if (Speed != 150)
				Speed = (int)Math.Round(Speed - Math.Pow(Speed - 150, 2) * decrementMultiplier);
			if (Heading != 150)
				Heading = (int)(Heading - Math.Sign(Heading - 150) * decrementMultiplier);

			if (Heading == 150 && Speed == 150)
				DecrementTimer.Stop();
		}
		#endregion

		#region Control methods
		public void Throttle(Direction d)
		{
			if (d == Direction.up)
				Speed += speedIncrement;
			else if (d == Direction.down)
				Speed -= speedIncrement;
		}

		public void Throttle(Direction d, bool initial)
		{
			if (!initial)
			{
				Throttle(d);
				return;
			}

			if (d == Direction.up)
				Speed += speedIncrementInitial;
			else if (d == Direction.down)
				Speed -= speedIncrementInitial;
		}

		public void Steer(Direction d)
		{
			if (d == Direction.left)
				Heading -= directionIncrement;
			else if (d == Direction.right)
				Heading += directionIncrement;
		}

		public void Steer(Direction d, bool initial)
		{
			if (!initial)
			{
				Steer(d);
				return;
			}

			if (d == Direction.left)
				Heading -= directionIncrementInitial;
			else if (d == Direction.right)
				Heading += directionIncrementInitial;
		}
		#endregion

		public int Clamp(int value, int min, int max)
		{
			if (value > max)
				return max;
			if (value < min)
				return min;
			return value;
		}

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
