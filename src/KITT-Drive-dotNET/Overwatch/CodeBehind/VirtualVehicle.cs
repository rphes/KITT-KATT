using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Media.Imaging;

namespace Overwatch
{
	public class VirtualVehicle
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
		public VirtualVehicle(Vehicle vehicle, Uri bitmap)
		{
			Vehicle = vehicle;
			Bitmap = new BitmapImage();
			Bitmap.BeginInit();
			Bitmap.UriSource = bitmap;
			Bitmap.EndInit();
		}
		#endregion

		#region Methods

		#endregion
	}
}
