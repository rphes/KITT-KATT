using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Media;
using Overwatch.Tools;

namespace Overwatch.ViewModel
{
	public class TraceViewModel : ObservableObject, IVisualizationObject
	{
		#region Data members
		// Position
		public double X { get; set; }
		public double Y { get; set; }

		double prevX;
		double prevY;

		// Appearance
		public Brush Stroke
		{
			get { return Brushes.Gray; }
		}
		private string _pathData = "";

		public string PathData
		{
			get { return _pathData; }
			set { 
				_pathData = value;
				RaisePropertyChanged("PathData");
			}
		}
		#endregion

		#region Construction
		public TraceViewModel(double x, double y)
		{
			X = x * Data.CanvasWidth;
			Y = (1-y) * Data.CanvasHeight;
			prevX = x;
			prevY = y;
		}
		#endregion

		#region Methods
		public void AddLineSegment(double x, double y)
		{
			double xrel, yrel;

			xrel = (x - prevX) * Data.CanvasWidth;
			yrel = -(y - prevY) * Data.CanvasHeight;
			if (PathData != "") 
				PathData += " ";
			else 
				PathData += "m 0 0 ";
			PathData += "l " + (int)Math.Round(xrel) + " " + (int)Math.Round(yrel);
			prevX = x;
			prevY = y;
		}
		#endregion

	}
}
