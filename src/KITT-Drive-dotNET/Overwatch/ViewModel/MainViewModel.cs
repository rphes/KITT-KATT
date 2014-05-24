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
		public int WindowWidth { get { return 900; } }
		public int WindowHeight { get { return WindowWidth / 3 * 2; } }
		public int DefaultMargin { get { return 5; } }
		public int VisualisationGroupBoxWidth { get { return (int)(WindowWidth / 3 * 2 - 3 * DefaultMargin); } }
		public int ObservationControlGroupBoxWidth { get { return (int)(WindowWidth / 3 - 3 * DefaultMargin); } }

		private VehicleViewModel _vehicleViewModel = new VehicleViewModel();
		public VehicleViewModel VehicleViewModel
		{
			get { return _vehicleViewModel; }
			set { _vehicleViewModel = value; }
		}
	}
}
