using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Threading;
using MLApp;

namespace SerialApp
{
	public class Matlab : IDisposable
	{
		MLApp.MLApp matlab;
		public DispatcherTimer SerialPoller;
		public string SerialTx = "";
		bool disposed, firsttick = true;

		public Matlab()
		{
			//Init teh Matlab
			matlab = new MLApp.MLApp();
			if (matlab.Visible != 1)
				matlab.MaximizeCommandWindow();

			SerialPoller = new DispatcherTimer();
			SerialPoller.Interval = new TimeSpan(0, 0, 0, 0, 100);
			SerialPoller.Tick += SerialPoller_Tick;

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


			PutRxData();
			GetTxData();
		}

		~Matlab()
		{
			Dispose(false);
		}

		public void Dispose()
		{
			Dispose(true);
			GC.SuppressFinalize(this);
		}

		protected virtual void Dispose(bool disposing)
		{
			if (!this.disposed)
			{
				if (disposing)
					matlab.Quit();

				disposed = true;
			}
				
		}

		void PutRxData()
		{
			//push the last received line to matlab
			string serialrx;

			try
			{
				serialrx = matlab.GetCharArray("serialrx", "base");
				if (serialrx != Data.serial.LastLine)
					matlab.PutCharArray("serialtx", "base", Data.serial.LastLine);
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
				if (serialtx != SerialTx)
					Data.serial.SendString(SerialTx);
			}
			catch (Exception exc)
			{
				System.Diagnostics.Debug.WriteLine(exc.Message);
			}
		}
	}
}
