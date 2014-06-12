using Overwatch.Tools;
using System;
using System.Windows.Media.Imaging;

namespace Overwatch.ViewModel
{
	/// <summary>
	/// Provides binding data for displaying a miniature vehicle in the visualization canvas, using data from an instance of the Vehicle class.
	/// </summary>
	public class VirtualVehicleViewModel : ObservableObject, IVisualizationObject
	{
		#region Data members
		// Base vehicle
		public Vehicle Vehicle { get; protected set; }

		// Position
		public double X { get { return Vehicle.X * Data.CanvasWidth - Width / 2; } set { } }
		public double Y { get { return (1 - Vehicle.Y) * Data.CanvasHeight - Height / 2; } set { } }

		// Rotation
		public double Angle { get { return -Vehicle.Angle; } }
		
		// Dimensions
		public double Width { get { return Data.CanvasWidth / Data.FieldSize * Vehicle.Width * 2; } }
		public double Height { get { return Data.CanvasHeight / Data.FieldSize * Vehicle.Height * 2; } }

		// Graphics
		public BitmapImage Bitmap { get; set; }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs an instance of the VirtualVehicleViewModel class, requiring a base vehicle and vehicle image.
		/// </summary>
		/// <param name="vehicle">The base vehicle.</param>
		/// <param name="bitmap">The bitmap image to display in the visualization canvas.</param>
		public VirtualVehicleViewModel(Vehicle vehicle, Uri bitmap)
		{
			Data.MainViewModel.VehicleViewModel.PropertyChanged += VehicleViewModel_PropertyChanged;

			Vehicle = vehicle;
			Bitmap = new BitmapImage();
			Bitmap.BeginInit();
			Bitmap.UriSource = bitmap;
			Bitmap.EndInit();
		}
		#endregion

		#region Event handling
		/// <summary>
		/// Sends a notification to the gui whenever base vehicle parameters have changed.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		void VehicleViewModel_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
		{
			RaisePropertyChanged("X");
			RaisePropertyChanged("Y");
			RaisePropertyChanged("Angle");
		}
		#endregion
	}
}
