using Overwatch.Tools;
using System.Windows.Media;

namespace Overwatch.ViewModel
{
	/// <summary>
	/// Provides binding data for a waypoint in the visualization canvas, based on an instance of the Waypoint class.
	/// </summary>
	public class WaypointViewModel : ObservableObject, IVisualizationObject
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
			get { return Waypoint.X * Data.CanvasWidth; }
			set
			{
				Waypoint.X = value / Data.CanvasWidth;
				RaisePropertyChanged("X");
			}
		}

		public double Y
		{
			get { return (1 - Waypoint.Y) * Data.CanvasHeight; }
			set
			{
				Waypoint.Y = 1 - (value / Data.CanvasHeight);
				RaisePropertyChanged("Y");
			}
		}

		public bool Visited
		{
			get { return Waypoint.Visited; }
			set
			{
				Waypoint.Visited = value;
				RaisePropertyChanged("Fill");
			}
		}

		public bool Current
		{
			get { return Waypoint.Current; }
			set
			{
				Waypoint.Current = value;
				RaisePropertyChanged("Fill");
			}
		}

		public int Index { get; set; }

		public string IndexString
		{
			get
			{
				if (Visited)
				{
					Index = -1;
					return "";
				}
				else
					return Index.ToString();
			}
		}

		// Appearance
		public Brush Stroke
		{
			get { return Brushes.Black; }
		}
		public Brush Fill
		{
			get
			{
				if (Current)
					return Brushes.Yellow;
				else if (!Visited)
					return Brushes.Red;
				else
					return Brushes.LightGreen;
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
			Visited = false;
			PathData = "m 0 0 v -50 L 15 -40 L 0 -30";
		}

		/// <summary>
		/// Constructs an instance of the WaypointViewModel class at the given location
		/// </summary>
		/// <param name="x">The position of the waypoint on the X-axis</param>
		/// <param name="y">The position of the waypoint on the Y-axis</param>
		public WaypointViewModel(double x, double y)
			: this()
		{
			X = x;
			Y = y;
		}
		#endregion
	}
}