using Overwatch.Tools;
using System;
using System.ComponentModel;
using System.IO;
using System.Windows;
using System.Windows.Input;

namespace Overwatch.ViewModel
{
	/// <summary>
	/// Provides general binding data and commands for the visualisation canvas.
	/// </summary>
	public class VisualisationViewModel : ObservableObject
	{
		#region Data members
		public int CanvasSize { get { return Data.CanvasSize; } }

		public VirtualVehicleViewModel KITT { get; protected set; }

		public BindingList<IVisualisationObject> Objects { get; set; }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the VisualisationViewModel class.
		/// </summary>
		public VisualisationViewModel()
		{
			Objects = new BindingList<IVisualisationObject>();

			// Add KITT to our visualisation canvas
			KITT = new VirtualVehicleViewModel(Data.MainViewModel.VehicleViewModel.Vehicle, new Uri(Directory.GetCurrentDirectory() + @"\Content\KITT.png"));

			Data.MainViewModel.VehicleViewModel.Vehicle.X = 0.5;
			Data.MainViewModel.VehicleViewModel.Vehicle.Y = 0.5;

			Objects.Add(KITT);
		}
		#endregion

		#region Methods
		/// <summary>
		/// Adds an object, of the type as selected in the gui, to the visualisation canvas, on the given location.
		/// </summary>
		/// <param name="x">The object's location on the X-axis.</param>
		/// <param name="y">The object's location on the Y-axis.</param>
		public void PlaceObject (double x, double y)
		{
			string s = Data.MainViewModel.AutoControlViewModel.SelectedObject;

			if (s == "Waypoint")
			{
				// Add a waypoint
				WaypointViewModel w = Data.MainViewModel.AutoControlViewModel.AutoControl.AddWaypoint(x, y);
				Objects.Add(w);
			}
		}

		/// <summary>
		/// Remove an object from the visualisation canvas.
		/// </summary>
		/// <param name="o">The object to remove.</param>
		public void RemoveObject (IVisualisationObject o)
		{
			if ((o as WaypointViewModel) != null)
			{
				// Remove a waypoint
				Data.MainViewModel.AutoControlViewModel.AutoControl.RemoveWaypoint((WaypointViewModel)o);
			}

			Objects.Remove(o);
		}
		#endregion

		#region Commands
		/// <summary>
		/// Performs the required actions when the visualisation canvas is clicked.
		/// </summary>
		/// <param name="e"></param>
		void MouseUpExecute(MouseButtonEventArgs e)
		{
			var src = e.OriginalSource as IInputElement;
			double x = e.GetPosition(src as IInputElement).X;
			double y = e.GetPosition(src as IInputElement).Y;
			
			if (e.OriginalSource.GetType().FullName != "System.Windows.Controls.Canvas")
			{
				// Remove an existing object
				IVisualisationObject o = (IVisualisationObject)(src as FrameworkElement).DataContext;
				RemoveObject(o);
			}
			else
				PlaceObject(x, y); // Place a new object	
		}

		bool CanMouseUpExecute(MouseButtonEventArgs e)
		{
			return true;
		}

		public ICommand MouseUp { get { return new RelayCommand<MouseButtonEventArgs>(MouseUpExecute, CanMouseUpExecute); } }
		#endregion
	}
}
