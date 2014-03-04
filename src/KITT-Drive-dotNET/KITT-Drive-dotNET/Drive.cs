using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace KITT_Drive_dotNET
{
	enum Direction
	{
	      up, down, left, right
	}

	class Drive : INotifyPropertyChanged
	{
		const int speedstep = 10;
		const int dirstep = 10;

		private int _speed;

		public int Speed
		{
			get { return _speed; }
			set
			{
				_speed = value;
				NotifyPropertyChanged("Speed");
			}
		}

		private int _dir;

		public int Dir
		{
			get { return _dir; }
			set 
			{
				_dir = value;
				NotifyPropertyChanged("Dir");
			}
		}

		public Drive()
		{
			Speed = 150;
			Dir = 150;
		}
		
		public void Throttle(Direction d)
		{
			if (d == Direction.up)
				Speed += speedstep;
			else if (d == Direction.down)
				Speed -= speedstep;
		}

		public void Steer(Direction d)
		{
			if (d == Direction.left)
				Dir -= dirstep;
			else if (d == Direction.right)
				Dir += dirstep;

		}

		public event PropertyChangedEventHandler PropertyChanged;

		private void NotifyPropertyChanged([CallerMemberName] String propertyName = "")
		{
			if (PropertyChanged != null)
			{
				PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
			}
		}

	}
}
