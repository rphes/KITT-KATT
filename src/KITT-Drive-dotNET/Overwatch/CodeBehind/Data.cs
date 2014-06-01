using Overwatch.ViewModel;

namespace Overwatch
{
	/// <summary>
	/// Provides access to all modules, as well as some global constants and methods
	/// </summary>
	public static class Data
	{
		#region Global constants
		//Field
		public static int CanvasSize { get { return 600; } } //600 px default
		public static int FieldSize { get { return 10; } } //10 meter
		#endregion

		#region Modules
		public static MainViewModel MainViewModel = new MainViewModel();
		#endregion

		#region Utility methods
		/// <summary>
		/// Clamps a value between a given minimum and maximum
		/// </summary>
		/// <param name="value">The value to clamp</param>
		/// <param name="min">The minimum clamped value</param>
		/// <param name="max">The maximum clamped value</param>
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
