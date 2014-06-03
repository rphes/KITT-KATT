using System;
using System.IO;
using System.IO.Ports;

namespace Overwatch
{
	public delegate void StatusReceivedEventHandler(object sender, EventArgs e);

	/// <summary>
	/// Holds all data and methods to be able to communicate with the vehicle via a serial connection.
	/// </summary>
	public class Communication : IDisposable
	{
		#region Data members
		public SerialPort SerialPort { get; private set; }

		private string lineBuffer = "";
		private string _lastLine;

		public string LastLine
		{
			get { return _lastLine; }
			protected set { _lastLine = value; }
		}

		private string _lastError;

		public string LastError
		{
			get { return _lastError; }
			protected set { _lastError = value; }
		}		
		
		DateTime lastStatusRequest;
		DateTime lastStatusResponse;
		public TimeSpan Ping;

		public event StatusReceivedEventHandler StatusReceived;

		#endregion

		#region Construction/Destruction
		/// <summary>
		/// Constructs a default instance of the Communication class.
		/// </summary>
		public Communication()
		{
			SerialPort = new SerialPort();
			SerialPort.BaudRate = 115200;
			SerialPort.Parity = Parity.None;
			SerialPort.DataBits = 8;
			SerialPort.StopBits = StopBits.One;
			SerialPort.Handshake = Handshake.None;
			SerialPort.ReceivedBytesThreshold = 1;
			SerialPort.ReadTimeout = 500;
			SerialPort.WriteTimeout = 500;
			SerialPort.DataReceived += serialPort_DataReceived;

			LastError = "";
			LastLine = "";
		}

		~Communication()
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
			if (disposing)
			{
				if (SerialPort != null)
					SerialPort.Close();
			}
		}

		public int OpenPort()
		{
			try
			{
				SerialPort.Open();
				return 0;
			}
			catch (IOException e)
			{
				LastError = e.Message;
				return -1;
			}
			catch (ArgumentException e)
			{
				LastError = e.Message;
				return -2;
			}
			catch (InvalidOperationException e)
			{
				LastError = e.Message;
				return -3;
			}
			catch (UnauthorizedAccessException e)
			{
				LastError = e.Message;
				return -4;
			}
			catch (Exception e)
			{
				LastError = e.Message;
				return 1;
			}
		}
		#endregion

		#region Transmission
		/// <summary>
		/// Send a string over the connected COM-port, a newline character ('\n') is appended.
		/// </summary>
		/// <param name="data">The string to send, without trailing newline character ('\n').</param>
		public void SendString(string data)
		{
			if (!SerialPort.IsOpen)
				return;

			try
			{
				SerialPort.WriteLine(data);
				if (data != "S")
					System.Diagnostics.Debug.WriteLine(data);
			}
			catch (Exception e)
			{
				LastError = e.Message;
				System.Diagnostics.Debug.WriteLine("Error occurred while sending string: " + data);
				return;
			}
		}

		/// <summary>
		/// Send a status request to the vehicle.
		/// </summary>
		public void RequestStatus()
		{
			SendString("S");
			lastStatusRequest = DateTime.Now;
		}

		/// <summary>
		/// Send a command to the vehicle to change its speed and direction.
		/// </summary>
		/// <param name="dir">The new PWM value for direction.</param>
		/// <param name="speed">The new PWM value for speed.</param>
		public void DoDrive(int dir, int speed)
		{
			string dirstring = dir.ToString();
			string speedstring = speed.ToString();
			string stringbuffer = 'D' + dirstring + ' ' + speedstring;

			SendString(stringbuffer);
		}

		/// <summary>
		/// Send a command to the vehicle to toggle its audio beacon.
		/// </summary>
		public void ToggleAudio()
		{
			bool b = !Data.MainViewModel.VehicleViewModel.BeaconIsEnabled;
			SendString("A" + (b ? "0" : "1"));
		}
		#endregion

		#region Reception
		/// <summary>
		/// Parse a single line of the vehicle's response to status variables.
		/// </summary>
		/// <param name="response">The response to parse.</param>
		private void parseResponse(string response)
		{
			response = response.Trim();
			char responseType = response[0];
			string responseTypeAlt = response.Split(' ')[0];

			if (responseTypeAlt == "Drive:" || responseTypeAlt == "L/R:")
			{
				int value;
				string data = response.Split(' ')[1].TrimEnd('%');

				if (int.TryParse(data, out value))
				{
					if (responseTypeAlt == "Drive:")
						Data.MainViewModel.VehicleViewModel.ActualPWMSpeed = value;
					else if (responseTypeAlt == "L/R:")
						Data.MainViewModel.VehicleViewModel.ActualPWMHeading = value;
				}

			}
			else if (responseType == 'D' || responseType == 'U')
			{
				int value1, value2;
				string[] data = response.Substring(1).Split(' ');

				if (int.TryParse(data[0], out value1) && int.TryParse(data[1], out value2))
				{
					if (responseType == 'D')
					{
						// Current drive commands
						Data.MainViewModel.VehicleViewModel.ActualPWMHeading = value1;
						Data.MainViewModel.VehicleViewModel.ActualPWMSpeed = value2;

						// Complete status transmission received, calculate ping
						lastStatusResponse = DateTime.Now;
						Ping = lastStatusResponse - lastStatusRequest;

						if (StatusReceived != null)
							StatusReceived(this, new EventArgs());
					}
					else if (responseType == 'U')
					{
						// Ultrasonic sensor readout
						Data.MainViewModel.VehicleViewModel.SensorDistanceLeft = value1;
						Data.MainViewModel.VehicleViewModel.SensorDistanceRight = value2;
					}
				}
			}
			else if (responseType == 'A')
			{
				if (response.Length > 5 && response.Substring(0, 5) == "Audio")
				{
					// Audio status readout
					if (response.Length == 7)
					{
						char c = response[response.Length - 1];
						if (c == '0')
							Data.MainViewModel.VehicleViewModel.BeaconIsEnabled = true;
						else
							Data.MainViewModel.VehicleViewModel.BeaconIsEnabled = false;
					}				
				}
				else
				{
					// Battery voltage readout
					int voltage;
					string data = response.Substring(1);

					if (int.TryParse(data, out voltage))
						Data.MainViewModel.VehicleViewModel.BatteryVoltage = voltage;
				}
			}
			
			else
			{
				System.Diagnostics.Debug.WriteLine("Received unknown response: " + response + "could not parse...");
			}
		}
		#endregion

		#region Serial event handling
		/// <summary>
		/// Event handler for performing the required actions when data is received through the serial connection.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		void serialPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
		{
			int rx;

			while (SerialPort.BytesToRead > 0)
			{
				try
				{
					rx = SerialPort.ReadByte();
				}
				catch (Exception exc)
				{
					LastError = exc.Message;
					return;
				}

				if (rx == 10)
				{
					LastLine = lineBuffer; // Line feed received, push linebuffer to output
					lineBuffer = "";
					parseResponse(LastLine);
				}
				else if (rx == 4)
					continue; // EOT received, discard and continue
				else
					lineBuffer += (char)rx;
			}
		}
		#endregion
	}
}
