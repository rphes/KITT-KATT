using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace Overwatch.ViewModel
{
	public class VisualisationViewModel : ObservableObject
	{
		BitmapImage BitmapKITT = new BitmapImage();
		public ImageSource ImageSourceKITT { get; set; }

		public Point KITTLocation = new Point(300,300);
		public double X { get { return KITTLocation.X; } }
		public double Y { get { return KITTLocation.Y; } }

		public VisualisationViewModel()
		{
			BitmapKITT.BeginInit();
			BitmapKITT.UriSource = new Uri(@"D:\Users\Robin\Documents\GitHub\KITT-KATT\src\KITT-Drive-dotNET\Overwatch\bin\Debug\resource\KITT.png");
			BitmapKITT.EndInit();
			ImageSourceKITT = BitmapKITT;
		}
	}
}
