using Overwatch.Tools;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
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
		public int CanvasWidth { get { return Data.CanvasWidth; } }
		public int CanvasHeight { get { return Data.CanvasHeight; } }

		//public FieldViewModel Field { get; set; }

		private VirtualVehicleViewModel _kitt;
		public VirtualVehicleViewModel KITT
		{
			get { return _kitt; }
			protected set
			{
				_kitt = value;
				RaisePropertyChanged("Objects");
			}
		}

		public ObservableCollection<WaypointViewModel> WaypointViewModels { get; set; }

		//public ObservableCollection<MicrophoneViewModel> Microphones { get; set; }

		public List<IVisualisationObject> Objects
		{
			get 
			{
				if (WaypointViewModels == null /*|| Microphones == null*/ || KITT == null)
					return null;

				List<IVisualisationObject> l = new List<IVisualisationObject>(WaypointViewModels);
				//l.AddRange(Microphones);
				l.Add(KITT);
				//l.Add(Field);
				return l;
			} 
		}
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the VisualisationViewModel class.
		/// </summary>
		public VisualisationViewModel()
		{
			// Add the field to our visualisation canvas
			//Field = new FieldViewModel();

			// Add KITT to our visualisation canvas
			KITT = new VirtualVehicleViewModel(Data.MainViewModel.VehicleViewModel.Vehicle, new Uri(Directory.GetCurrentDirectory() + @"\Content\KITT.png"));

			Data.MainViewModel.VehicleViewModel.Vehicle.X = 0.7;
			Data.MainViewModel.VehicleViewModel.Vehicle.Y = 0.3;
			Data.MainViewModel.VehicleViewModel.Vehicle.Angle = 45;

			WaypointViewModels = new ObservableCollection<WaypointViewModel>();
			WaypointViewModels.CollectionChanged += ObjectsChanged;
			//Microphones = new ObservableCollection<MicrophoneViewModel>();
			//Microphones.CollectionChanged += ObjectsChanged;
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
				WaypointViewModel w = new WaypointViewModel(x, y);
				w.Index = Data.MainViewModel.AutoControlViewModel.AutoControl.QueuedWaypoints.Count;
				Data.MainViewModel.AutoControlViewModel.AutoControl.AddWaypoint(w.Waypoint);
				WaypointViewModels.Add(w);
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
				WaypointViewModel wvm = (WaypointViewModel)o;
				Data.MainViewModel.AutoControlViewModel.AutoControl.RemoveWaypoint(wvm.Waypoint);
				WaypointViewModels.Remove(wvm);
				UpdateWaypointViewModelIndices();
			}

		}

		public void UpdateWaypointViewModelIndices()
		{
			int i = 0;
			foreach(WaypointViewModel wvm in WaypointViewModels)
			{
				if (!wvm.Visited)
				{
					wvm.Index = i;
					i++;
				}
			}
		}
		#endregion

		#region Event handling
		/// <summary>
		/// Notifies the gui that the objects in the visualisation canvas have changed. 
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		void ObjectsChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
		{
			RaisePropertyChanged("Objects");
		}
		#endregion

		#region Commands
		#region Mouse left button up
		/// <summary>
		/// Performs the required actions when the left mouse button is released on the visualisation canvas.
		/// </summary>
		/// <param name="e"></param>
		void MouseLeftButtonUpExecute(MouseButtonEventArgs e)
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

		bool CanMouseLeftButtonUpExecute(MouseButtonEventArgs e)
		{
			return true;
		}

		public ICommand MouseLeftButtonUp { get { return new RelayCommand<MouseButtonEventArgs>(MouseLeftButtonUpExecute, CanMouseLeftButtonUpExecute); } }
		#endregion

		#region Mouse right button up
		/// <summary>
		/// Performs the required actions when the left mouse button is released on the visualisation canvas.
		/// </summary>
		/// <param name="e"></param>
		void MouseRightButtonUpExecute(MouseButtonEventArgs e)
		{
			var src = e.OriginalSource as IInputElement;

			if ((src as FrameworkElement) != null)
			{
				// Manually finish a waypoint
				if (((src as FrameworkElement).DataContext as WaypointViewModel) != null)
				{
					WaypointViewModel wvm = (WaypointViewModel)((FrameworkElement)src).DataContext;
					if (!wvm.Visited)
					{
						Data.MainViewModel.AutoControlViewModel.AutoControl.FinishWaypoint(wvm.Waypoint);
						wvm.Visited = true;
					}
					else
					{
						Data.MainViewModel.AutoControlViewModel.AutoControl.UnFinishWaypoint(wvm.Waypoint);
						wvm.Visited = false;
					}
					UpdateWaypointViewModelIndices();
				}
			}
			RaisePropertyChanged("Objects");
		}
		
		bool CanMouseRightButtonUpExecute(MouseButtonEventArgs e)
		{
			return true;
		}

		public ICommand MouseRightButtonUp { get { return new RelayCommand<MouseButtonEventArgs>(MouseRightButtonUpExecute, CanMouseRightButtonUpExecute); } }
		#endregion
		#endregion
	}
}
