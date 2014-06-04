using Overwatch.Tools;
using System.Windows;
using System.Windows.Media;

namespace Overwatch.ViewModel
{
	/// <summary>
	/// Provides binding data for a waypoint in the visualisation canvas, based on an instance of the Waypoint class.
	/// </summary>
	public class WaypointViewModel : ObservableObject, IVisualisationObject
	{
		#region Data members
		private Waypoint _waypoint = new Waypoint();

		public Waypoint Waypoint
		{
			get { return _waypoint; }
			set { _waypoint = value; }
		}

		// Position
		public double X 
		{
			get { return Waypoint.X; }
			set
			{
				Waypoint.X = value;
				RaisePropertyChanged("X");
			}
		}

		public double Y
		{
			get { return Waypoint.Y; }
			set
			{
				Waypoint.Y = value;
				RaisePropertyChanged("Y");
			}
		}

		// Appearance
		private Brush _stroke;
		public Brush Stroke
		{
			get { return _stroke; }
			set
			{
				_stroke = value;
				RaisePropertyChanged("Stroke");
			}
		}
		private Brush _fill;
		public Brush Fill
		{
			get { return _fill; }
			set
			{
				_fill = value;
				RaisePropertyChanged("Fill");
			}
		}
		private string _pathData;
		public string PathData
		{
			get { return _pathData; }
			set
			{
				_pathData = value;
				RaisePropertyChanged("PathData");
			}
		}
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the WaypointViewModel class
		/// </summary>
		public WaypointViewModel()
		{
			Stroke = Brushes.Black;
			Fill = Brushes.Blue;
			PathData = "m 0 0 v 100 L 30 80 L 0 60";
		}

		/// <summary>
		/// Constructs an instance of the WaypointViewModel class at the given location
		/// </summary>
		/// <param name="x">The position of the waypoint on the X-axis</param>
		/// <param name="y">The position of the waypoint on the Y-axis</param>
		public WaypointViewModel(double x, double y) : this()
		{
			X = x;
			Y = y;
		}
		#endregion
	}
}
