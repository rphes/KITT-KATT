using System;
using System.IO;
using System.IO.Ports;
using System.Text;

namespace KITT_Drive_dotNET
{
	public class SerialInterface : ISerial, IDisposable
	{
		#region Data members
		public SerialPort SerialPort;
		public string LastError = "";
		public event EventHandler<SerialDataEventArgs> SerialDataEvent;
		public int BytesInTBuffer { get { return SerialPort.BytesToWrite; } }
		public int BytesInRBuffer { get { return SerialPort.BytesToRead; } }
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
			System.Diagnostics.Debug.WriteLine("Sent string: " + data);
		}

		public void RequestStatus()
		{
			SendString("S");

			//return this.RetrieveAnswer();
		}

		public void DoDrive(int dir, int speed)
		{
			string dirstring = dir.ToString();
			string speedstring = speed.ToString();
			string stringbuffer = 'D' + dirstring + ' ' + speedstring;

			SendString(stringbuffer);
		}

		public void ToggleAudio(int enable)
		{
			SendString('A' + enable.ToString());
		}
		#endregion

		private void parseResponse(string response)
		{
			//response = response.Trim(new char[] { ' ',  });
			char type = response[0];
		}

		//#region Reception
		//private string RetrieveAnswer()
		//{
		//	char[] charRead = new char[1];
		//	StringBuilder answer = new StringBuilder();

		//	// Read while a character not equal to end of
		//	// transmission is read

		//	SerialPort.Read(charRead, 0, 1); // Read first character

		//	while (Convert.ToInt16(charRead[0]) != 4) // Check for EoT
		//	{
		//		answer.Append(charRead);

		//		SerialPort.Read(charRead, 0, 1); // Read next character
		//	}

		//	return answer.ToString();
		//}

		//public struct AnswerStatus
		//{
		//	public bool valid;

		//	public int drive, steering;
		//	public int sensorLeft, sensorRight;
		//	public int batteryVoltage;
		//	public bool audioStatus;
		//}

		//private AnswerStatus ConvertStatusAnswer(string answer)
		//{
		//	AnswerStatus status = new AnswerStatus();

		//	String stripped;
		//	String[] splitted;

		//	String[] answerSplitted = answer.Split('\n'); // Split on newline

		//	// Check if the number of lines returned is correct
		//	if (answerSplitted.Length != 4)
		//	{
		//		status.valid = false;
		//		return status;
		//	}
		//	else
		//	{
		//		status.valid = true;
		//	}

		//	// Find drive and steering value
		//	stripped = answerSplitted[0].Substring(1, answer.Length - 1); // Strip 'D' from the beginning
		//	splitted = stripped.Split(' ');
		//	status.drive = Convert.ToInt16(splitted[0]);
		//	status.steering = Convert.ToInt16(splitted[1]);

		//	// Find sensor values
		//	stripped = answerSplitted[1].Substring(1, answer.Length - 1); // Strip 'S' from the beginning
		//	splitted = stripped.Split(' ');
		//	status.sensorLeft = Convert.ToInt16(splitted[0]);
		//	status.sensorRight = Convert.ToInt16(splitted[1]);

		//	// Find battery voltage
		//	stripped = answerSplitted[2].Substring(1, answer.Length - 1); // Strip 'A' from the beginning
		//	status.batteryVoltage = Convert.ToInt16(stripped);

		//	// Find audio status
		//	stripped = answerSplitted[3].Substring(6, answer.Length - 1); // Strip 'Audio ' from the beginning
		//	status.audioStatus = Convert.ToBoolean(stripped);

		//	return status;
		//}
		//#endregion

		#region Serial event handling
		void serialPort_ErrorReceived(object sender, SerialErrorReceivedEventArgs e)
		{
			//MessageBox.Show();
			throw new NotImplementedException();
		}

		void serialPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
		{
			string input = SerialPort.ReadLine();
			System.Diagnostics.Debug.WriteLine("Serial string received: " + input);


		}

		#endregion
	}
}
