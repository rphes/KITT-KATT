using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SerialApp
{
	public static class Data
	{
		public static bool FakeKITT = false;
		public static SerialInterface serial = new SerialInterface();
		public static Matlab matlab = new Matlab();
		public static Vehicle car = new Vehicle();
		public static FakeKITT fake = new FakeKITT();
	}
}
