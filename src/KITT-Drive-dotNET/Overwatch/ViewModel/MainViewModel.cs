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
		private VehicleViewModel _vehicleViewModel = new VehicleViewModel();
		public VehicleViewModel VehicleViewModel
		{
			get { return _vehicleViewModel; }
			set { _vehicleViewModel = value; }
		}

		private CommunicationViewModel _communicationViewModel = new CommunicationViewModel();
		public CommunicationViewModel CommunicationViewModel
		{
			get { return _communicationViewModel; }
			set { _communicationViewModel = value; }
		}

		private VisualisationViewModel _visualisationViewModel = new VisualisationViewModel();
		public VisualisationViewModel VisualisationViewModel
		{
			get { return _visualisationViewModel; }
			set { _visualisationViewModel = value; }
		}
	}
}
