using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace Overwatch.ViewModel
{
	public class MicrophoneViewModel : IVisualizationObject
	{
		// Position
		public double X { get; set; }
		public double Y { get; set; }
		public Brush Stroke { get { return Brushes.Black; } }
	}
}
