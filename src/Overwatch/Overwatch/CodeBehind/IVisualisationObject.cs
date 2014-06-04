namespace Overwatch
{
	/// <summary>
	/// Provides a bare minimum to which objects to be placed in the visualisation canvas should comply.
	/// </summary>
	public interface IVisualisationObject
	{
		#region Data members
		/// <summary>
		/// The position of the object on the X-axis.
		/// </summary>
		double X { get; set; }
		/// <summary>
		/// The position of the object on the Y-axis.
		/// </summary>
		double Y { get; set; }
		#endregion
	}
}
