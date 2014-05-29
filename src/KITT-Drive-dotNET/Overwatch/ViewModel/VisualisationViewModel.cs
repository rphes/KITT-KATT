using Overwatch.Tools;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace Overwatch.ViewModel
{
	public class VisualisationViewModel : ObservableObject
	{
		#region Data members
		public int CanvasSize { get { return Data.CanvasSize; } }

		public VirtualVehicle KITT { get; protected set; }
		public double KITT_X { get { return KITT.X; } }
		public double KITT_Y { get { return KITT.Y; } }
		public double KITT_W { get { return KITT.Width; } }
		public double KITT_H { get { return KITT.Height; } }
		#endregion

		#region Construction
		public VisualisationViewModel()
		{
			KITT = new VirtualVehicle(Data.MainViewModel.VehicleViewModel.Vehicle, new Uri(Directory.GetCurrentDirectory() + @"\Content\KITT.png"));

			//For testing
			Data.MainViewModel.VehicleViewModel.Vehicle.X = 0.5;
			Data.MainViewModel.VehicleViewModel.Vehicle.Y = 0.5;
		}
		#endregion

		#region Commands
		void MouseUpExecute(MouseButtonEventArgs e)
		{
			//For testing
			Data.MainViewModel.VehicleViewModel.Vehicle.X = e.GetPosition(e.OriginalSource as IInputElement).X / Data.CanvasSize;
			Data.MainViewModel.VehicleViewModel.Vehicle.Y = e.GetPosition(e.OriginalSource as IInputElement).Y / Data.CanvasSize;
			RaisePropertyChanged("KITT_X");
			RaisePropertyChanged("KITT_Y");
		}

		bool CanMouseUpExecute(MouseButtonEventArgs e)
		{
			return true;
		}

		public ICommand MouseUp { get { return new RelayCommand<MouseButtonEventArgs>(MouseUpExecute, CanMouseUpExecute); } }
		#endregion
	}
}
