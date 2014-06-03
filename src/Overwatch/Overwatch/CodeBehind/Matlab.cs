using System;
using System.ComponentModel;

namespace Overwatch
{
	/// <summary>
	/// Holds all data and methods to be able to make use of MATLAB from within this application, using the MATLAB COM Automation Server
	/// </summary>
	public class Matlab
	{
		#region Data members
		public MLApp.MLApp Instance { get; protected set; }
		private BackgroundWorker matlabStarter = new BackgroundWorker();

		public bool Running { get { return Instance != null; } }
		public bool Visible { get { return Instance.Visible == 1; } }
		#endregion

		#region Construction
		/// <summary>
		/// Constructs a default instance of the Matlab class
		/// </summary>
		public Matlab()
		{
			matlabStarter.WorkerSupportsCancellation = false;
			matlabStarter.WorkerReportsProgress = false;
			matlabStarter.DoWork += matlabStarter_DoWork;
			matlabStarter.RunWorkerAsync();
		}

		/// <summary>
		/// Start the MATLAB COM Automation Server via a BackgroundWorker
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		void matlabStarter_DoWork(object sender, DoWorkEventArgs e)
		{
			Instance = new MLApp.MLApp();
		}
		#endregion

		#region Methods
		/// <summary>
		/// Show the MATLAB command window
		/// </summary>
		public void Show()
		{
			if (Running && !Visible)
				Instance.MaximizeCommandWindow();
		}

		/// <summary>
		/// Hide the MATLAB command window
		/// </summary>
		public void Hide()
		{
			if (Running && Visible)
				Instance.MinimizeCommandWindow();
		}

		/// <summary>
		/// Close MATLAB and dereference its instance
		/// </summary>
		public void Quit()
		{
			if (Instance != null)
			{
				Instance.Quit();
				Instance = null;
			}
		}

		/// <summary>
		/// Push an object to MATLAB
		/// </summary>
		/// <param name="name">The variable name in MATLAB</param>
		/// <param name="workspace">The MATLAB workspace in which the variable resides</param>
		/// <param name="data">The data to push</param>
		/// <returns>True if succesful, false if not</returns>
		public bool PutVariable(string name, string workspace, object data)
		{
			if (Instance == null) return false;

			try
			{
				Instance.PutWorkspaceData(name, "base", data);
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.Message);
				return false;
			}

			return true;
		}

		/// <summary>
		/// Push an object to MATLAB, in the "base" (default) workspace
		/// </summary>
		/// <param name="name">The variable name in MATLAB</param>
		/// <param name="data">The data to push</param>
		/// <returns>True if succesful, false if not</returns>
		public object PutVariable(string name, object data)
		{
			return PutVariable(name, "base", data);
		}

		/// <summary>
		/// Get an object from MATLAB
		/// </summary>
		/// <param name="name">The variable name in MATLAB</param>
		/// <param name="workspace">The MATLAB workspace in which the variable resides</param>
		/// <returns>The object if succesful, null if not</returns>
		public object GetVariable(string name, string workspace)
		{
			if (Instance == null) return null;

			object obj;

			try
			{
				Instance.GetWorkspaceData(name, workspace, out obj);
				System.Diagnostics.Debug.WriteLine(obj.ToString());
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.Message);
				return null;
			}

			return obj;
		}

		/// <summary>
		/// Get an object from MATLAB, from the "base" (default) workspace
		/// </summary>
		/// <param name="name">The variable name in MATLAB</param>
		/// <returns>The object if succesful, null if not</returns>
		public object GetVariable(string name)
		{
			return GetVariable(name, "base");
		}
		#endregion
	}
}
