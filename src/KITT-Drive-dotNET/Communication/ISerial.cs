using System;
using System.IO.Ports;

namespace KITT_Drive_dotNET
{
    interface ISerial
    {
        event EventHandler<SerialDataEventArgs> SerialDataEvent;       
    }
}
