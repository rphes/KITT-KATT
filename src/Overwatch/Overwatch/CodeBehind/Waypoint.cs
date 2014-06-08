using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Overwatch
{
	/// <summary>
	/// Holds all required data and methods for displaying a waypoint in the visualisation canvas.
	/// </summary>
	public class Waypoint
	{
		#region Data members
		public double X { get; set; }
		public double Y { get; set; }
		public bool Visited { get; set; }
		#endregion
	}
}
