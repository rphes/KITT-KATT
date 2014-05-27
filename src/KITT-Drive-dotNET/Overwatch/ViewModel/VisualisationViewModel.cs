using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace Overwatch.ViewModel
{
	public class VirtualKITT
	{
		public static double RealWidth { get { return 0.4; } }
		public static double RealHeight { get { return 0.3; } }
		public double X { get; set; }
		public double Y { get; set; }
		public double W { get { return Data.CanvasSize / Data.FieldSize * RealWidth *5; } }
		public double H { get { return Data.CanvasSize / Data.FieldSize * RealHeight *5; } }
		public double Scale { get; set; }
		public BitmapImage Bitmap { get; set; }

		public VirtualKITT()
		{
			Bitmap = new BitmapImage();
		}

		public void SetLocation(double x, double y)
		{
			X = x * Scale - W / 2;
			Y = y * Scale - H / 2;
		}
	}

	public class VisualisationViewModel : ObservableObject
	{
		public int CanvasSize { get { return Data.CanvasSize; } }
		BitmapImage BitmapKITT = new BitmapImage();
		public ImageSource ImageSourceKITT { get; set; }
		public VirtualKITT KITT { get; set; }

		public VisualisationViewModel()
		{
			KITT = new VirtualKITT();
			KITT.Scale = Data.CanvasSize;
			KITT.Bitmap.BeginInit();
			KITT.Bitmap.UriSource = new Uri(Directory.GetCurrentDirectory() + @"\Content\KITT.png");
			KITT.Bitmap.EndInit();
			KITT.SetLocation(0.5, 0.5);
		}
	}
}
