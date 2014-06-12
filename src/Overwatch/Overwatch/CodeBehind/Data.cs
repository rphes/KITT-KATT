using Overwatch.ViewModel;
using System;
using System.IO;
using System.Windows;

namespace Overwatch
{
	public delegate void SrcDirectoryNotFoundEventHandler(object sender, EventArgs e);

	/// <summary>
	/// Provides access to all modules, as well as some global constants and methods.
	/// </summary>
	public static class Data
	{
		public static event SrcDirectoryNotFoundEventHandler SrcDirectoryNotFound;

		#region Global constants
		// Field
		public static int CanvasWidth { get { return 700; } }
		public static int CanvasHeight { get { return 700; } }
		public static int FieldSize { get { return 7; } } //10 meter
		#endregion

		#region Global parameters
		public static bool FindSrcDirectoryFailed = false;
		private static DirectoryInfo _srcDirectory;
		public static DirectoryInfo SrcDirectory
		{
			get
			{
				if (_srcDirectory == null && !FindSrcDirectoryFailed)
				{
					// Find current directory
					string dir = Directory.GetCurrentDirectory();
					// Try to find containing "src" directory
					int i = dir.IndexOf("src");
					if (i == -1)
					{
						if (SrcDirectoryNotFound != null && !FindSrcDirectoryFailed)
						{
							FindSrcDirectoryFailed = true;
							SrcDirectoryNotFound(null, new EventArgs());
						}
						_srcDirectory = null;
					}
					else
					{
						// Found "src" directory, save and return
						dir = dir.Substring(0, i + 3);
						_srcDirectory = new DirectoryInfo(dir);
					}
				}

				return _srcDirectory; 
			}
		} 
		#endregion

		#region Modules
		public static MainViewModel MainViewModel = new MainViewModel();
		#endregion

		#region Utility methods
		/// <summary>
		/// Clamps a value between a given minimum and maximum.
		/// </summary>
		/// <param name="value">The value to clamp.</param>
		/// <param name="min">The minimum clamped value.</param>
		/// <param name="max">The maximum clamped value.</param>
		/// <returns></returns>
		public static double Clamp(double value, double min, double max)
		{
			if (value > max)
				return max;
			if (value < min)
				return min;
			return value;
		}
		#endregion
	}
}
