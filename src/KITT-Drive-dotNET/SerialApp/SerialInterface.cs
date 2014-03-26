using System;
using System.IO;
using System.IO.Ports;
using System.Text;

namespace SerialApp
{
	public class SerialInterface : ObservableObject, IDisposable
	{
		#region Data members
		public SerialPort SerialPort;
		public int BytesInTBuffer { get { return SerialPort.BytesToWrite; } }
		public int BytesInRBuffer { get { return SerialPort.BytesToRead; } }

		private string _textBuffer;

		public string TextBuffer
		{
			get { return _textBuffer; }
			protected set
			{ 
				_textBuffer = value;
				NotifyPropertyChanged("TextBuffer");
			}
		}

		private string _lastError;

		public string LastError
		{
			get { return _lastError; }
			protected set { _lastError = value; }
		}

		private string _lastLine;

		public string LastLine
		{
			get { return _lastLine; }
			protected set { _lastLine = value; }
		}
		
		
		#endregion

		#region Construction/Destruction
		public SerialInterface()
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
			SerialPort.ErrorReceived += serialPort_ErrorReceived;

			LastError = "";
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
				// free managed resources
				if (SerialPort != null)
				{
					SerialPort.Close();
					SerialPort.Dispose();
				}
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
		public void SendByte(Byte data)
		{
			byte[] buf = { data };
			SerialPort.Write(buf, 0, 1);
			System.Diagnostics.Debug.WriteLine("Serial byte sent: {0:X}", data);
		}

		/// <summary>
		/// Send a string over the connected COM-port, a newline character ('\n') is appended
		/// </summary>
		/// <param name="data">The string to send, without trailing newline character ('\n')</param>
		public void SendString(string data)
		{
			try
			{
				SerialPort.WriteLine(data);
			}
			catch (Exception e)
			{
				LastError = e.Message;
				System.Diagnostics.Debug.WriteLine("Error occurred while sending string: " + data);
				return;
			}
			TextBuffer += "Sent: " + data + '\n';
		}
		#endregion

		#region Reception
		private void parseResponse(string response)
		{
			char responseType = response[0];
			string responseTypeAlt = response.Split(' ')[0];

			if (responseType == 'S')
			{

			}
			else if (responseTypeAlt == "Drive:" || responseTypeAlt == "L/R:")
			{
				int value;
				string data = response.Split(' ')[1].TrimEnd('%');

				if (int.TryParse(data, out value))
				{
					if (responseTypeAlt == "Drive:")
						Data.car.ActualPWMSpeed = value;
					else if (responseTypeAlt == "L/R:")
						Data.car.ActualPWMHeading = value;
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
						//current drive commands
						Data.car.ActualPWMHeading = value1;
						Data.car.ActualPWMSpeed = value2;
					}
					else if (responseType == 'U')
					{
						//ultrasonic sensor readout
						Data.car.SensorDistanceLeft = value1;
						Data.car.SensorDistanceRight = value2;
					}
				}
			}
			else if (responseType == 'A')
			{
				//battery voltage readout
				int voltage;
				string data = response.Substring(1);

				if (int.TryParse(data, out voltage))
					Data.car.BatteryVoltage = voltage;
			}
			else if (response.Substring(0, 5) == "Audio")
			{
				//audio status readout
				bool audiostatus = response[-1] != 0;
				Data.car.AudioStatus = audiostatus;
			}
			else
			{
				System.Diagnostics.Debug.WriteLine("Received unknown response: " + response + "could not parse...");
			}

			Data.fake.CalculateNewState();
		}
		#endregion

		#region Serial event handling
		void serialPort_ErrorReceived(object sender, SerialErrorReceivedEventArgs e)
		{
			throw new NotImplementedException();
		}

		void serialPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
		{
			int rx;
			string linebuffer = "";

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

				char c = (char)rx;

				if (c != '\n')
					linebuffer += (char)rx;
				else
				{
					LastLine = linebuffer;
					linebuffer = "";
					if (!String.IsNullOrEmpty(LastLine))
						parseResponse(LastLine);
				}

				TextBuffer += (char)rx;
			}
		}

		#endregion
	}
}
