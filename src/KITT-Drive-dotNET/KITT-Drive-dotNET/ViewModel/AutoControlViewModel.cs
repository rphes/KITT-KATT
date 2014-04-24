using OxyPlot;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

namespace KITT_Drive_dotNET.ViewModel
{
	public enum AutoControlStatus {StringEmpty, ParseFailed, NoTimeIncrement, Unbalanced, Ready, Running};

	public class AutoControlViewModel : ObservableObject
	{
		#region Properties
		private AutoControl _autoControl = new Model3AutoControl();

		public AutoControl AutoControl
		{
			get { return _autoControl; }
			set { _autoControl = value; }
		}
		
		private string _xRefString;

		public string xRefString
		{
			get { return _xRefString; }
			set
			{
				_xRefString = value;
				RaisePropertyChanged("xRefString");
			}
		}

		private string _tRefString;

		public string tRefString
		{
			get { return _tRefString; }
			set
			{
				_tRefString = value;
				RaisePropertyChanged("tRefString");
			}
		}

		public List<int> xRefList
		{
			get { return AutoControl.xRefList; }
			set { AutoControl.xRefList = value; }
		}

		public List<int> tRefList
		{
			get { return AutoControl.tRefList; }
			set { AutoControl.tRefList = value; }
		}

		public int xRefValue
		{
			get
			{ 
				if (ControlModeSliderIsEnabled)
					return xRefList[0];

				return 0;
			}
			set
			{
				if (ControlModeSliderIsEnabled)
				{
					xRefList = new List<int>();
					xRefList.Add(value);
					//tRefList = new List<int>();
					//tRefList.Add(0);
					RaisePropertyChanged("xRefValueString");
				}
			}
		}

		public string xRefValueString { get { return "Target distance: " + xRefValue + " cm from wall"; } }

		private bool _controlModeSliderIsEnabled;

		public bool ControlModeSliderIsEnabled
		{
			get { return _controlModeSliderIsEnabled; }
			set
			{
				_controlModeSliderIsEnabled = value;
				RaisePropertyChanged("ControlModeSliderIsEnabled");
			}
		}

		private bool _controlModeTextArrayIsEnabled = true;

		public bool ControlModeTextArrayIsEnabled
		{
			get { return _controlModeTextArrayIsEnabled; }
			set
			{
				_controlModeTextArrayIsEnabled = value;
				RaisePropertyChanged("ControlModeTextArrayIsEnabled");
			}
		}

		public bool ExpectedValueFilterIsEnabled
		{
			get { return AutoControl.ExpectedValueFilterIsEnabled; }
			set
			{
				AutoControl.ExpectedValueFilterIsEnabled = value;
				RaisePropertyChanged("ExpectedValueFilterIsEnabled");
			}
		}

		public bool LowPassFilterIsEnabled
		{
			get { return AutoControl.LowPassFilterIsEnabled; }
			set
			{
				AutoControl.LowPassFilterIsEnabled = value;
				RaisePropertyChanged("LowPassFilterIsEnabled");
			}
		}

		private AutoControlStatus _status = AutoControlStatus.StringEmpty;

		public AutoControlStatus Status
		{
			get {return _status;}
			protected set
			{
				_status = value;
				RaisePropertyChanged("Status");
				RaisePropertyChanged("StatusString");
				RaisePropertyChanged("StatusStringColor");
				RaisePropertyChanged("StartStopButtonString");
			}
		}
		
		public Dictionary<AutoControlStatus, string> StatusDict = new Dictionary<AutoControlStatus, string>();

		public string StatusString
		{
			get { return StatusDict[Status]; }
		}

		public SolidColorBrush StatusStringColor
		{
			get 
			{
				if (Status == AutoControlStatus.Running)
					return new SolidColorBrush(Colors.Blue);
				else if (Status != AutoControlStatus.Ready)
					return new SolidColorBrush(Colors.Red);
				else
					return new SolidColorBrush(Colors.Green);
			}
		}

		public string StartStopButtonString
		{
			get
			{
				if (Status == AutoControlStatus.Running)
					return "Stop";

				return "Go!";
			}
		}

		public string ScaleString { get; set; }
		public string PoleString { get; set; }
		public string GearRatioString { get; set; }
		public string WeightString { get; set; }

		double scale, pole, weight;
		int gear;

		//Plot data
		public double PlotMinimum { get { return PlotMaximum - AutoControl.MaxTimeSpan; } }
		public double PlotMaximum {
			get
			{
				if (YPoints != null && YPoints.Count > 1 && YPoints[YPoints.Count - 1].X > AutoControl.MaxTimeSpan)
					return Math.Floor(YPoints[YPoints.Count - 1].X / (AutoControl.MaxTimeSpan * 0.8)) * AutoControl.MaxTimeSpan * 0.8 + 0.8 * AutoControl.MaxTimeSpan;

				return AutoControl.MaxTimeSpan;
			} 
		}

		public List<DataPoint> YPoints { get { return makeDatapoints(AutoControl.TBuffer, AutoControl.YBuffer); } }
		public List<DataPoint> VPoints { get { return makeDatapoints(AutoControl.TBuffer, AutoControl.VBuffer); } }
		public List<DataPoint> RPoints { get { return makeDatapoints(AutoControl.TBuffer, AutoControl.RBuffer); } }
		public List<DataPoint> XPoints { get { return makeDatapoints(AutoControl.TBuffer, AutoControl.XBuffer); } }

		public string PingString { get { return Math.Round(Data.MainViewModel.CommunicationViewModel.Communication.Ping.TotalMilliseconds) + " ms"; } }

		#endregion

		#region Construction
		public AutoControlViewModel()
		{
			//Build status dictionary
			StatusDict.Add(AutoControlStatus.NoTimeIncrement, "Time must increment");
			StatusDict.Add(AutoControlStatus.StringEmpty, "Enter reference values");
			StatusDict.Add(AutoControlStatus.ParseFailed, "Could not parse reference values");
			StatusDict.Add(AutoControlStatus.Unbalanced, "State and time reference series must be of equal length");
			StatusDict.Add(AutoControlStatus.Ready, "Ready");
			StatusDict.Add(AutoControlStatus.Running, "Running");
			
		}
		#endregion

		#region Methods
		public void Start()
		{
			if (xRefList == null)
			{
				xRefList = new List<int>();
				xRefList.Add(0);
				tRefList = new List<int>();
				tRefList.Add(0);
			}
			Status = AutoControlStatus.Running;
			AutoControl.Start();
		}

		public void Stop()
		{
			Status = AutoControlStatus.Ready;
			AutoControl.Stop();
		}
		List<int> parseRefString(string s)
		{
			if (String.IsNullOrEmpty(s))
			{
				Status = AutoControlStatus.StringEmpty;
				return null;
			}

			List<int> ints = new List<int>();
			string[] split = s.Split(' ');

			foreach (string str in split)
			{
				int parsed;
				if (!int.TryParse(str, out parsed))
				{
					Status = AutoControlStatus.ParseFailed;
					return null;
				}
				ints.Add(parsed);
			}

			return ints;
		}

		bool validateRefs()
		{
			xRefList = parseRefString(xRefString);
			tRefList = parseRefString(tRefString);

			if (xRefList == null || tRefList == null)
				return false;
			
			int prev = -1;
			foreach (int t in tRefList)
			{
				if (t <= prev)
				{
					Status = AutoControlStatus.NoTimeIncrement;
					return false; //Timestamps should always increment
				}
				prev = t;
			}

			if (tRefList.Count != xRefList.Count)
			{
				Status = AutoControlStatus.Unbalanced;
				return false; //Ref lists should of be equal length
			}

			Status = AutoControlStatus.Ready;
			return true;
		}

		public void UpdatePlot()
		{
			RaisePropertyChanged("PlotMaximum");
			RaisePropertyChanged("PlotMinimum");
			RaisePropertyChanged("YPoints");
			RaisePropertyChanged("VPoints");
			RaisePropertyChanged("RPoints");
			RaisePropertyChanged("XPoints");
		}

		List<DataPoint> makeDatapoints(List<double> xPoints, List<double> yPoints)
		{
			if (xPoints == null || yPoints == null)				
				return null;

			//if (xPoints.Count != yPoints.Count)
			//	throw new System.ArgumentException("The count of both input queues must be equal");
				
			List<DataPoint> l = new List<DataPoint>();

			for (int i = 0; i < xPoints.Count-1; i++)
				l.Add(new DataPoint(xPoints[i], yPoints[i]));

			return l;
		}
		#endregion

		#region Commands
		void StartStopExecute()
		{
			if (Status != AutoControlStatus.Running)
				Start();
			else
				Stop();
		}

		bool CanStartStopExecute()
		{
			if (Status == AutoControlStatus.Running)
				return true;
			else if (ControlModeTextArrayIsEnabled)
				return validateRefs();
			else
				return true;
		}

		public ICommand StartStop { get { return new RelayCommand(StartStopExecute, CanStartStopExecute); } }

		void ReinitializeExecute()
		{
			if (AutoControl.GetType().Name == "Model2AutoControl")
				AutoControl = new Model2AutoControl();
			else if (AutoControl.GetType().Name == "Model3AutoControl")
				AutoControl = new Model3AutoControl(scale, weight, gear);

			AutoControl.placeCompensatorPoles(pole);
		}

		bool CanReinitializeExecute()
		{
			if (Double.TryParse(ScaleString, out scale) &&
				Double.TryParse(WeightString, out weight) &&
				Double.TryParse(PoleString, out pole) &&
				Int32.TryParse(GearRatioString, out gear) &&
				Status != AutoControlStatus.Running)
				return true;
			else
				return false;
		}

		public ICommand Reinitialize { get { return new RelayCommand(ReinitializeExecute, CanReinitializeExecute); } }
		#endregion		
	}
}
