using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Media.Imaging;

namespace Overwatch.ViewModel
{
	public class MicrophoneViewModel : IVisualisationObject
	{
		// Position
		public double X { get; set; }
		public double Y { get; set; }

		// Dimensions
		public double Width { get { return Data.CanvasWidth / Data.FieldSize * Vehicle.Width * 5; } }
		public double Height { get { return Data.CanvasHeight / Data.FieldSize * Vehicle.Height * 5; } }

		// Graphics
		public BitmapImage Bitmap { get; set; }

		public MicrophoneViewModel(Vehicle vehicle, Uri bitmap)
		{
			Bitmap = new BitmapImage();
			Bitmap.BeginInit();
			Bitmap.UriSource = bitmap;
			Bitmap.EndInit();
		}
	}
}
