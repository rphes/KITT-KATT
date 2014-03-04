using System;
using System.IO;
using System.IO.Ports;

namespace KITT_Drive_dotNET
{
    public class SerialInterface : ISerial, IDisposable
    {
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
            serialPort.PinChanged += serialPort_PinChanged;
            
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
        public void SendByte(Byte data)
        {
            byte[] buf = {data};
            serialPort.Write(buf,0,1);
			System.Diagnostics.Debug.WriteLine("Serial byte sent: {0:X}", data);
        }
		public void RequestStatus()
		{
			char[] buf = { 'S', '\n' };
			serialPort.Write(buf, 0, buf.Length);
		}
		public void DoDrive(int dir, int speed)
		{
			char[] buf = { 'D', (char)dir, (char)speed, '\n'};
			serialPort.Write(buf, 0, buf.Length);
		}
		public void ToggleAudio(int enable)
		{
			char[] buf = { 'A', (char)enable, '\n'};
			serialPort.Write(buf, 0, buf.Length);
		}
        void serialPort_PinChanged(object sender, SerialPinChangedEventArgs e)
        {
            serialPort.Close();
            serialPort.Open();
        }

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
    }
}
