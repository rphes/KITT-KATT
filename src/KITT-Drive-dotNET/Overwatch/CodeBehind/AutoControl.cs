using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Threading;

namespace Overwatch
{
	public class AutoControl
	{
		#region Data members
		public bool Enabled { get; set; }
		#endregion

		#region Construction
		public AutoControl()
		{
			Enabled = false;
			//Subscribe to status updates
			Data.MainViewModel.CommunicationViewModel.Communication.StatusReceived += Communication_StatusReceived;
		}
		#endregion

		#region Event handling
		void Communication_StatusReceived(object sender, EventArgs e)
		{
			if (!Enabled) return;

			//Run required functions

			//Request new status
			Data.MainViewModel.CommunicationViewModel.Communication.RequestStatus();
		}
		#endregion
	}
}
