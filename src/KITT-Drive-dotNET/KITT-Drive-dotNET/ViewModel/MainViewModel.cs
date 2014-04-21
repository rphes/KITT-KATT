using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace KITT_Drive_dotNET.ViewModel
{
	public class MainViewModel
	{
		private CommunicationViewModel _communicationViewModel = new CommunicationViewModel();

		public CommunicationViewModel CommunicationViewModel
		{
			get { return _communicationViewModel; }
			set { _communicationViewModel = value; }
		}

		private ControlViewModel _controlViewModel = new ControlViewModel();

		public ControlViewModel ControlViewModel
		{
			get { return _controlViewModel; }
			set { _controlViewModel = value; }
		}

		private AutoControlViewModel _autoControlViewModel = new AutoControlViewModel();

		public AutoControlViewModel AutoControlViewModel
		{
			get { return _autoControlViewModel; }
			set { _autoControlViewModel = value; }
		}

		private VehicleViewModel _vehicleViewModel = new VehicleViewModel();

		public VehicleViewModel VehicleViewModel
		{
			get { return _vehicleViewModel; }
			set { _vehicleViewModel = value; }
		}
		
	}
}
