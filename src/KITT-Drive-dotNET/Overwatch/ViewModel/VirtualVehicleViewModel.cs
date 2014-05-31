using Overwatch.Tools;
using System;
using System.Windows.Media.Imaging;

namespace Overwatch.ViewModel
{
	/// <summary>
	/// Provides binding data for displaying a miniature vehicle in the visualisation canvas, using data from an instance of the Vehicle class
	/// </summary>
	public class VirtualVehicleViewModel : ObservableObject
	{
		#region Data members
		//Base vehicle
		public Vehicle Vehicle { get; protected set; }

		//Position
		public double X { get { return Vehicle.X * Data.CanvasSize - Width / 2; } }
		public double Y { get { return Vehicle.Y * Data.CanvasSize - Height / 2; } }
		
		//Dimensions
		public double Width { get { return Data.CanvasSize / Data.FieldSize * Vehicle.Width * 5; } }
		public double Height { get { return Data.CanvasSize / Data.FieldSize * Vehicle.Height *5; } }

		//Graphics
		public BitmapImage Bitmap { get; set; }
		#endregion

		#region Construction
		public VirtualVehicleViewModel(Vehicle vehicle, Uri bitmap)
		{
			Data.MainViewModel.VehicleViewModel.PropertyChanged += VehicleViewModel_PropertyChanged;

			Vehicle = vehicle;
			Bitmap = new BitmapImage();
			Bitmap.BeginInit();
			Bitmap.UriSource = bitmap;
			Bitmap.EndInit();
		}

		void VehicleViewModel_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
		{
			RaisePropertyChanged("X");
			RaisePropertyChanged("Y");
		}
		#endregion

		#region Methods

		#endregion
	}
}
