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
	public class Model3AutoControl : AutoControl
	{
		#region Construction
		public Model3AutoControl()
		{
			double c = Data.MotorConstant / Data.WheelRadius / Data.GearRatio; //Gyration constant

			//Build model specific matrices
			A = DenseMatrix.OfArray(new double[,] { { 0, 1, 0 }, { 0, -Data.RollingResistance / Data.Mass, c / Data.Mass }, { 0, -c / Data.MotorInductance, -Data.MotorResistance / Data.MotorInductance } });
			B = DenseMatrix.OfArray(new double[,] { { 0 }, { 0 }, { 1 / Data.MotorInductance } });
			C = DenseMatrix.OfArray(new double[,] { { 1, 0, 0 } });
			x = DenseMatrix.OfArray(new double[,] { { 0 }, { 0 } });
		}
		#endregion
	}
}
