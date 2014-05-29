using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Overwatch.ViewModel;

namespace Overwatch
{
	public static class Data
	{
		#region Global constants
		//Field
		public static int CanvasSize { get { return 600; } } //600 px default
		public static int FieldSize { get { return 10; } } //10 meter
		#endregion

		#region Modules
		public static MainViewModel MainViewModel = new MainViewModel();
		#endregion

		#region Utility methods
		public static double Clamp(double value, double min, double max)
		{
			if (value > max)
				return max;
			if (value < min)
				return min;
			return value;
		}

		public static double Snap(double value, double snap, double min, double max)
		{
			if (value < max && value > min)
				return snap;
			else
				return value;
		}
		#endregion
	}

	public enum Direction
	{
		up, down, left, right
	}


}
