using System;

namespace Overwatch
{
	/// <summary>
	/// Holds all data and methods to be able to make use of MATLAB from within this application, using the MATLAB COM Automation Server
	/// </summary>
	public class Matlab
	{
		#region Data members
		MLApp.MLApp matlab;

		public bool Connected
		{
			get
			{
				if (matlab == null || matlab.Visible == 0)
					return false;
				else
					return true;
			}
		}
		#endregion

		#region Construction
		public Matlab()
		{
		}
		#endregion

		#region Methods
		/// <summary>
		/// Initialise an instance of MATLAB and make the command window visible
		/// </summary>
		public void Connect()
		{
			matlab = new MLApp.MLApp();
			if (matlab.Visible != 1)
				matlab.MaximizeCommandWindow();
		}

		/// <summary>
		/// Close MATLAB and dereference the current instance
		/// </summary>
		public void Disconnect()
		{
			if (matlab != null)
			{
				matlab.Quit();
				matlab = null;
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
			if (matlab == null) return false;

			try
			{
				matlab.PutWorkspaceData(name, "base", data);
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
			if (matlab == null) return null;

			object obj;

			try
			{
				matlab.GetWorkspaceData(name, workspace, out obj);
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
