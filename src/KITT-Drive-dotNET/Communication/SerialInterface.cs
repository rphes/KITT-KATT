using System;
using System.IO;
using System.IO.Ports;
using System.Text;

namespace KITT_Drive_dotNET
{
    public class SerialInterface : ISerial, IDisposable
	{
		#region Data members
		string port;
        int baudrate;
        SerialPort serialPort;
        public string lastError = "";
        public event EventHandler<SerialDataEventArgs> SerialDataEvent;
        public bool IsOpen
        {
            get
            {
                return serialPort.IsOpen;
            }
        }
        public int BytesInTBuffer
        {
            get
            {
                return serialPort.BytesToWrite;
            }
        }
        public int BytesInRBuffer
        {
            get
            {
                return serialPort.BytesToRead;
            }
        }
		#endregion

		#region Construction/Destruction
		public SerialInterface(string _port)
        {
            port = _port;
            baudrate = 115200;
            serialPort = new SerialPort();
            serialPort.PortName = port;
            serialPort.BaudRate = baudrate;
            serialPort.Parity = Parity.None;
            serialPort.DataBits = 8;
            serialPort.StopBits = StopBits.One;
            serialPort.Handshake = Handshake.None;
            serialPort.ReceivedBytesThreshold = 1;
            serialPort.ReadTimeout = 500;
            serialPort.WriteTimeout = 500;
            serialPort.DataReceived += serialPort_DataReceived;
            serialPort.ErrorReceived += serialPort_ErrorReceived;
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
                if (serialPort != null)
                {
                    serialPort.Close();
                    serialPort.Dispose();
                }
            }            
        }

        public int OpenPort()
        {
            try
            {
                serialPort.Open();
                return 0;
            }
            catch (IOException e)
            {
                //MessageBox.Show("SerialInterface Error:\n" + e.Message, "SerialInterface Error", MessageBoxButton.OK, MessageBoxImage.Error);
                lastError = e.Message;
                return -1;
            }
            catch (ArgumentException e)
            {
                //MessageBox.Show("SerialInterface Error:\n" + e.Message, "SerialInterface Error", MessageBoxButton.OK, MessageBoxImage.Error);
                lastError = e.Message;
                return -2;
            }
            catch (InvalidOperationException e)
            {
                //MessageBox.Show("SerialInterface Error:\n" + e.Message, "SerialInterface Error", MessageBoxButton.OK, MessageBoxImage.Error);
                lastError = e.Message;
                return -3;
            }
            catch (UnauthorizedAccessException e)
            {
                //MessageBox.Show("SerialInterface Error:\n" + e.Message, "SerialInterface Error", MessageBoxButton.OK, MessageBoxImage.Error);
                lastError = e.Message;
                return -4;
            }
            catch (Exception e)
            {
                //MessageBox.Show("SerialInterface Error:\n" + e.Message, "SerialInterface Error", MessageBoxButton.OK, MessageBoxImage.Error);
                lastError = e.Message;
                return 1;
            }
        }
		#endregion

		#region Transmission
		public void SendByte(Byte data)
        {
            byte[] buf = {data};
            serialPort.Write(buf,0,1);
			System.Diagnostics.Debug.WriteLine("Serial byte sent: {0:X}", data);
        }

		public string RequestStatus()
		{
			char[] buf = { 'S', '\n' };
			serialPort.Write(buf, 0, buf.Length);

            return this.RetrieveAnswer();
		}

		public void DoDrive(int dir, int speed)
		{
			string dirstring = dir.ToString();
			string speedstring = speed.ToString();
			string stringbuffer = 'D' + dirstring + ' ' + speedstring + '\n';
			System.Diagnostics.Debug.WriteLine("Sending string: " + stringbuffer);
			char[] buf = stringbuffer.ToCharArray();
			//serialPort.Write(buf, 0, buf.Length);
		}

		public void ToggleAudio(int enable)
		{
			char[] buf = { 'A', (char)enable, '\n'};
			serialPort.Write(buf, 0, buf.Length);
		}
		#endregion

        #region Reception
        private string RetrieveAnswer()
        {
            char[] charRead = new char[1];
            StringBuilder answer = new StringBuilder();

            // Read while a character not equal to end of
            // transmission is read

            serialPort.Read(charRead, 0, 1); // Read first character

            while (Convert.ToInt16(charRead) != 4) // Check for EoT
            {
                answer.Append(charRead);

                serialPort.Read(charRead, 0, 1); // Read next character
            }

            return answer.ToString();
        }

        public struct AnswerStatus
        {
            public bool valid;

            public int drive, steering;
            public int sensorLeft, sensorRight;
            public int batteryVoltage;
            public bool audioStatus;
        }

        private AnswerStatus ConvertStatusAnswer(string answer)
        {
            AnswerStatus status = new AnswerStatus();

            String stripped;
            String[] splitted;

            String[] answerSplitted = answer.Split('\n'); // Split on newline

            // Check if the number of lines returned is correct
            if (answerSplitted.Length != 4)
            {
                status.valid = false;
                return status;
            }
            else
            {
                status.valid = true;
            }

            // Find drive and steering value
            stripped = answerSplitted[0].Substring(1, answer.Length - 1); // Strip 'D' from the beginning
            splitted = stripped.Split(' ');
            status.drive = Convert.ToInt16(splitted[0]);
            status.steering = Convert.ToInt16(splitted[1]);

            // Find sensor values
            stripped = answerSplitted[1].Substring(1, answer.Length - 1); // Strip 'S' from the beginning
            splitted = stripped.Split(' ');
            status.sensorLeft = Convert.ToInt16(splitted[0]);
            status.sensorRight = Convert.ToInt16(splitted[1]);

            // Find battery voltage
            stripped = answerSplitted[2].Substring(1, answer.Length - 1); // Strip 'A' from the beginning
            status.batteryVoltage = Convert.ToInt16(stripped);

            // Find audio status
            stripped = answerSplitted[3].Substring(6, answer.Length - 1); // Strip 'Audio ' from the beginning
            status.audioStatus = Convert.ToBoolean(stripped);

            return status;
        }
        #endregion

        #region Serial event handling
        void serialPort_ErrorReceived(object sender, SerialErrorReceivedEventArgs e)
        {            
            //MessageBox.Show();
            throw new NotImplementedException();
        }

        void serialPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            int input = serialPort.ReadByte();
			System.Diagnostics.Debug.WriteLine("Serial byte received: {0:X}", input);
            DataSerial((byte)input, e);           
        }
    
        void DataSerial(Byte b, SerialDataReceivedEventArgs e)
        {
            // Do something before the event…
            OnSerialDataChanged(new SerialDataEventArgs(b,e));
            // or do something after the event. 
        }

        protected virtual void OnSerialDataChanged(SerialDataEventArgs e)
        {
            if (SerialDataEvent != null)
            {
                SerialDataEvent(this, e);
            }
		}
		#endregion
	}
}
