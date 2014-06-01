using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Threading;

namespace Overwatch
{
	/// <summary>
	/// Holds all required data and methods to enable autonomous control of the vehicle
	/// </summary>
	public class AutoControl
	{
		#region Data members
		public bool Enabled { get; set; }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the AutoControl class
		/// </summary>
		public AutoControl()
		{
			Enabled = false;
			//Subscribe to status updates
			Data.MainViewModel.CommunicationViewModel.Communication.StatusReceived += Communication_StatusReceived;
		}
		#endregion

		#region Event handling
		/// <summary>
		/// Performs the required actions whenever a new status update is received from the vehicle
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
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
