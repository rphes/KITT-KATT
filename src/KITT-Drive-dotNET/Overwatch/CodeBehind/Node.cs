namespace Overwatch
{
	/// <summary>
	/// Holds all required data and methods for displaying a node in the visualisation canvas
	/// </summary>
	public class Node
	{
		#region Data members
		//Position
		public double X { get; set; }
		public double Y { get; set; }

		//Dimensions
		public double Width { get; set; }
		public double Height { get; set; }
		#endregion

		#region Construction
		public Node()
		{
			Width = 20;
			Height = 20;
		}
		#endregion
	}
}
