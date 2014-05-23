using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

namespace Overwatch.ViewModel
{
	public class MainViewModel
	{
		public int WindowHorizontalSize { get { return 1024; } }
		public int WindowVerticalSize { get { return WindowHorizontalSize / 4 * 3; } }
		public int DefaultMargin { get { return 5; } }
		public int VisualisationGroupBoxHorizontalSize { get { return (int)(WindowHorizontalSize * 0.75); } }
		public int ObservationControlGroupBoxHorizontalSize { get { return (int)(WindowHorizontalSize * 0.25); } }
	}
}
