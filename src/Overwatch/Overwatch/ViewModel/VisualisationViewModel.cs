using Overwatch.Tools;
using System;
using System.Collections.Generic;
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
		private List<WaypointViewModel> WaypointViewModelQueue = new List<WaypointViewModel>();
		private List<WaypointViewModel> WaypointViewModelVisited = new List<WaypointViewModel>();

		public List<WaypointViewModel> WaypointViewModels
		{
			get
			{
				List<WaypointViewModel> l = new List<WaypointViewModel>(WaypointViewModelQueue);
				l.AddRange(WaypointViewModelVisited);
				return l;
			}
		}

		public TraceViewModel Trace;

		public List<MicrophoneViewModel> Microphones;

		public List<IVisualisationObject> Objects
		{
			get
			{
				if (WaypointViewModels == null || KITT == null)
					return null;

				List<IVisualisationObject> l = new List<IVisualisationObject>(WaypointViewModels);
				l.Add(KITT);
				if (Trace != null) l.Add(Trace);
				if (Microphones != null) l.AddRange(Microphones);
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
			// Add KITT to our visualisation canvas
			KITT = new VirtualVehicleViewModel(Data.MainViewModel.VehicleViewModel.Vehicle, new Uri(Directory.GetCurrentDirectory() + @"\Content\KITT.png"));

			Data.MainViewModel.VehicleViewModel.Vehicle.X = 0.7;
			Data.MainViewModel.VehicleViewModel.Vehicle.Y = 0.3;
			Data.MainViewModel.VehicleViewModel.Vehicle.Angle = 45;

			// Add default waypoints
			PlaceObject((double)2 / 7 * Data.CanvasWidth, (1 - (double)5 / 7) * Data.CanvasHeight);
			PlaceObject((double)6 / 7 * Data.CanvasWidth, (1 - (double)6 / 7) * Data.CanvasHeight);

			// Add microphones
			Microphones = new List<MicrophoneViewModel>();
			Microphones.Add(new MicrophoneViewModel() { X = 0 * Data.CanvasWidth - 10, Y = 1 * Data.CanvasHeight -10});
			Microphones.Add(new MicrophoneViewModel() { X = 0 * Data.CanvasWidth - 10, Y = 0 -10 });
			Microphones.Add(new MicrophoneViewModel() { X = 1 * Data.CanvasWidth - 10, Y = 1 * Data.CanvasHeight - 10 });
			Microphones.Add(new MicrophoneViewModel() { X = 1 * Data.CanvasWidth - 10, Y = 0 * Data.CanvasHeight - 10 });
			Microphones.Add(new MicrophoneViewModel() { X = 0.5 * Data.CanvasWidth - 10, Y = 1 * Data.CanvasHeight -10 });
			RaisePropertyChanged("Objects");
		}
		#endregion

		#region Methods
		/// <summary>
		/// Adds an object, of the type as selected in the gui, to the visualisation canvas, on the given location.
		/// </summary>
		/// <param name="x">The object's location on the X-axis.</param>
		/// <param name="y">The object's location on the Y-axis.</param>
		public void PlaceObject(double x, double y)
		{
			string s = Data.MainViewModel.AutoControlViewModel.SelectedObject;

			if (s == "Waypoint")
			{
				// Add a waypoint
				WaypointViewModel w = new WaypointViewModel(x, y);
				w.Index = Data.MainViewModel.AutoControlViewModel.AutoControl.QueuedWaypoints.Count;
				Data.MainViewModel.AutoControlViewModel.AutoControl.AddWaypoint(w.Waypoint);
				WaypointViewModelQueue.Add(w);
			}

			UpdateWaypointViewModels();
		}

		/// <summary>
		/// Remove an object from the visualisation canvas.
		/// </summary>
		/// <param name="o">The object to remove.</param>
		public void RemoveObject(IVisualisationObject o)
		{
			if ((o as WaypointViewModel) != null)
			{
				// Remove a waypoint
				WaypointViewModel wvm = (WaypointViewModel)o;
				Data.MainViewModel.AutoControlViewModel.AutoControl.RemoveWaypoint(wvm.Waypoint);

				if (wvm.Visited)
					WaypointViewModelVisited.Remove(wvm);
				else
					WaypointViewModelQueue.Remove(wvm);

				UpdateWaypointViewModels();
			}

		}

		/// <summary>
		/// Mark a waypoint as finished or not finished by moving it from the queue to the visited list or vice versa.
		/// </summary>
		/// <param name="w">The waypoint to mark as finished/not finished.</param>
		public void FinishWaypointViewModel(WaypointViewModel wvm)
		{
			if (wvm.Visited)
			{
				Data.MainViewModel.AutoControlViewModel.AutoControl.UnFinishWaypoint(wvm.Waypoint);
				WaypointViewModelQueue.Add(wvm);
				WaypointViewModelVisited.Remove(wvm);
				wvm.Visited = false;
			}
			else
			{
				Data.MainViewModel.AutoControlViewModel.AutoControl.FinishWaypoint(wvm.Waypoint);
				WaypointViewModelQueue.Remove(wvm);
				WaypointViewModelVisited.Add(wvm);
				wvm.Visited = true;
			}

			UpdateWaypointViewModels();
		}

		/// <summary>
		/// Marks the current WaypointViewModel as finished.
		/// </summary>
		public void FinishWaypointViewModel()
		{
			FinishWaypointViewModel(WaypointViewModelQueue[0]);
		}

		/// <summary>
		/// Swap two WaypointViewModels in the list.
		/// </summary>
		/// <param name="index1">The index of the first waypoint to swap.</param>
		/// <param name="index2">The index of the second waypoint to swap.</param>
		public void SwapWaypointViewModels(int index1, int index2)
		{
			Data.MainViewModel.AutoControlViewModel.AutoControl.SwapWaypoints(index1, index2);
			WaypointViewModel tmp = WaypointViewModelQueue[index1];
			WaypointViewModelQueue[index1] = WaypointViewModels[index2];
			WaypointViewModelQueue[index2] = tmp;

			UpdateWaypointViewModels();
		}

		/// <summary>
		/// Update the index stored in a WayPointViewModel for correct display in the visualisation canvas.
		/// </summary>
		public void UpdateWaypointViewModels()
		{
			int i = 0;
			foreach (WaypointViewModel wvm in WaypointViewModels)
			{
				if (!wvm.Visited)
				{
					wvm.Index = i;
					i++;
				}
				wvm.Current = false;
			}

			if (WaypointViewModelQueue.Count > 0)
				WaypointViewModelQueue[0].Current = true;

			RaisePropertyChanged("Objects");
		}

		/// <summary>
		/// Adds the current vehicle position to the trace for drawing in the visualisation canvas.
		/// </summary>
		public void UpdateTrace()
		{
			if (Trace == null)
				Trace = new TraceViewModel(Data.MainViewModel.VehicleViewModel.X, Data.MainViewModel.VehicleViewModel.Y);
			else
				Trace.AddLineSegment(Data.MainViewModel.VehicleViewModel.X, Data.MainViewModel.VehicleViewModel.Y);

			RaisePropertyChanged("Objects");
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
		/// Add or remove a waypoint when clicked with the left mouse button.
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
		/// Mark a waypoint as finished when clicked with the right mouse button.
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
					FinishWaypointViewModel(wvm);
				}
			}
		}

		bool CanMouseRightButtonUpExecute(MouseButtonEventArgs e)
		{
			return true;
		}

		public ICommand MouseRightButtonUp { get { return new RelayCommand<MouseButtonEventArgs>(MouseRightButtonUpExecute, CanMouseRightButtonUpExecute); } }
		#endregion

		#region MouseWheel
		/// <summary>
		/// Reorders the waypoints in the visualisation canvas on scroll events.
		/// </summary>
		/// <param name="e"></param>
		void MouseWheelExecute(MouseWheelEventArgs e)
		{
			var src = e.OriginalSource as IInputElement;

			if ((src as FrameworkElement) != null)
			{
				if (((src as FrameworkElement).DataContext as WaypointViewModel) != null)
				{
					WaypointViewModel wvm = (WaypointViewModel)((FrameworkElement)src).DataContext;
					if (!wvm.Visited)
					{
						int i = (int)Data.Clamp(wvm.Index + Math.Sign(e.Delta), 0, WaypointViewModelQueue.Count - 1);
						if (wvm.Index != i)
							SwapWaypointViewModels(wvm.Index, i);
					}
				}
			}
		}

		bool CanMouseWheelExecute(MouseWheelEventArgs e)
		{
			return true;
		}

		public ICommand MouseWheel { get { return new RelayCommand<MouseWheelEventArgs>(MouseWheelExecute, CanMouseWheelExecute); } }
		#endregion
		#endregion
	}
}