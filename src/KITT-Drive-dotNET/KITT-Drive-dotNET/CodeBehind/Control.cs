using System;
using System.Windows.Threading;

namespace KITT_Drive_dotNET
{
	/// <summary>
	/// Provides methods and properties for controlling KITT, as well as members for the GUI to bind to
	/// </summary>
	public class Control
	{
		#region Data members	
		public double Speed { get; set; }

		public int PWMSpeed { get; set; }

		public double Heading { get; set; }

		public int PWMHeading { get; set; }
		#endregion

	}
}
