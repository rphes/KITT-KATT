using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Threading;
using MLApp;

namespace SerialApp
{
	public class Matlab
	{
		MLApp.MLApp matlab;
		public DispatcherTimer SerialPoller;
		public string SerialTx = "";
		bool firsttick = true;
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

		public Matlab()
		{
			SerialPoller = new DispatcherTimer();
			SerialPoller.Interval = new TimeSpan(0, 0, 0, 0, 100);
			SerialPoller.Tick += SerialPoller_Tick;
		}

		public void Connect()
		{
			//Init teh Matlab
			matlab = new MLApp.MLApp();
			if (matlab.Visible != 1)
				matlab.MaximizeCommandWindow();
		}

		public void Disconnect()
		{
			if (matlab != null)
			{
				matlab.Quit();
				matlab = null;
			}
		}

		void SerialPoller_Tick(object sender, EventArgs e)
		{
			if (firsttick)
			{
				try
				{
					matlab.GetCharArray("serialtx", "base");	
				}
				catch
				{
					System.Diagnostics.Debug.WriteLine("Variable serialtx did not exist in workspace; creating for preventing further errors");
					matlab.PutCharArray("serialtx", "base", "");
				}
				try
				{
					matlab.GetCharArray("serialrx", "base");
				}
				catch
				{
					System.Diagnostics.Debug.WriteLine("Variable serialrx did not exist in workspace; creating for preventing further errors");
					matlab.PutCharArray("serialrx", "base", "");
				}

				firsttick = false;
			}

			//PutRxData();
			GetTxData();
		}

		public void PutRxData(string varname, object data)
		{
			if (matlab == null)
				return;

			//push data to matlab
			try
			{
				matlab.PutWorkspaceData(varname, "base", data);
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.Message);
			}
		}

		void GetTxData()
		{
			//try to get next serial command to send
			string serialtx;

			try
			{
				serialtx = matlab.GetCharArray("serialtx", "base");
				System.Diagnostics.Debug.WriteLine(serialtx);
				if (serialtx != SerialTx)
				{
					SerialTx = serialtx;
					Data.serial.SendString(SerialTx);
				}
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.Message);
			}
		}
	}
}
