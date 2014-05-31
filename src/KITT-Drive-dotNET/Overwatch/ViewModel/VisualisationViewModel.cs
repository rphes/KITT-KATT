using Overwatch.Tools;
using System;
using System.ComponentModel;
using System.IO;
using System.Windows;
using System.Windows.Input;

namespace Overwatch.ViewModel
{
	/// <summary>
	/// Provides general binding data and commands for the visualisation canvas
	/// </summary>
	public class VisualisationViewModel : ObservableObject
	{
		#region Data members
		public int CanvasSize { get { return Data.CanvasSize; } }

		public VirtualVehicleViewModel KITT { get; protected set; }

		public BindingList<object> Objects { get; set; }
		#endregion

		#region Construction
		public VisualisationViewModel()
		{
			KITT = new VirtualVehicleViewModel(Data.MainViewModel.VehicleViewModel.Vehicle, new Uri(Directory.GetCurrentDirectory() + @"\Content\KITT.png"));

			//For testing
			Data.MainViewModel.VehicleViewModel.Vehicle.X = 0.5;
			Data.MainViewModel.VehicleViewModel.Vehicle.Y = 0.5;

			Node node = new Node();
			node.X = 50;
			node.Y = 60;

			Objects = new BindingList<object>();
			Objects.Add(KITT);
			Objects.Add(node);
		}
		#endregion

		#region Commands
		void MouseUpExecute(MouseButtonEventArgs e)
		{
			//tests
			double x = e.GetPosition(e.OriginalSource as IInputElement).X;
			double y = e.GetPosition(e.OriginalSource as IInputElement).Y;
			Node node = new Node() { X = x, Y = y };
			Objects.Add(node);
		}

		bool CanMouseUpExecute(MouseButtonEventArgs e)
		{
			return true;
		}

		public ICommand MouseUp { get { return new RelayCommand<MouseButtonEventArgs>(MouseUpExecute, CanMouseUpExecute); } }
		#endregion
	}
}
