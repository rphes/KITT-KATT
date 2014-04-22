using MathNet.Numerics.LinearAlgebra.Double;
using MathNet.Numerics.LinearAlgebra.Generic;
using OxyPlot;
using System;
using System.Collections.Generic;
using System.Windows.Threading;

namespace KITT_Drive_dotNET
{
	/// <summary>
	/// Implements a system model, for tracking and controlling KITT
	/// </summary>
	public class Model2AutoControl : AutoControl
	{
		#region Construction
		public Model2AutoControl()
		{
			//Build model specific matrices
			A = DenseMatrix.OfArray(new double[,] { { 0, 1 }, { 0, -0.5063 } });
			B = DenseMatrix.OfArray(new double[,] { { 0 }, { 6.25 } });
			C = DenseMatrix.OfArray(new double[,] { { 1, 0 } });
			placeCompensatorPoles(-1);
			L = DenseMatrix.OfArray(new double[,] { { 7.7937 }, { 13.2544 } });
			x = DenseMatrix.OfArray(new double[,] { { 0 }, { 0 } });
		}
		#endregion
	}
}
