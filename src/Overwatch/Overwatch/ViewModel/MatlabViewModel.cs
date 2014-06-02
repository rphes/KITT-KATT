using Overwatch.Tools;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Input;

namespace Overwatch.ViewModel
{
	/// <summary>
	/// Provides binding data and commands for all MATLAB-related gui-elements, based on an instance of the Matlab class
	/// </summary>
	public class MatlabViewModel : ObservableObject
	{
		#region Data members
		public Matlab Matlab { get; protected set; }

		public string ToggleMatlabButtonString
		{
			get
			{
				if (Matlab.Connected)
					return "Close MATLAB";
				else
					return "Open MATLAB";
			}
		}
		#endregion

		#region Construction
		public MatlabViewModel()
		{
			Matlab = new Matlab();
		}
		#endregion

		#region Commands
		/// <summary>
		/// Opens or closes MATLAB
		/// </summary>
		void ToggleMatlabExecute()
		{
			if (Matlab.Connected)
				Matlab.Disconnect();
			else
				Matlab.Connect();
			RaisePropertyChanged("ToggleMatlabButtonString");
		}

		bool CanToggleMatlabExecute()
		{
			return true;
		}

		public ICommand ToggleMatlab { get { return new RelayCommand(ToggleMatlabExecute, CanToggleMatlabExecute); } }
		#endregion
	}
}
