using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SerialApp
{
	public static class Data
	{
		public static SerialInterface serial = new SerialInterface();
		public static Matlab matlab = new Matlab();
		public static Vehicle car = new Vehicle();
	}
}
