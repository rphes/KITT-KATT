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
		public VehicleViewModel VehicleViewModel { get; set; }

		public CommunicationViewModel CommunicationViewModel { get; set; }

		public VisualisationViewModel VisualisationViewModel { get; set; }

		public AutoControlViewModel AutoControlViewModel { get; set; }

		public void Init()
		{
			VehicleViewModel = new VehicleViewModel();
			CommunicationViewModel = new CommunicationViewModel();
			VisualisationViewModel = new VisualisationViewModel();
			AutoControlViewModel = new AutoControlViewModel();
		}
	}
}
