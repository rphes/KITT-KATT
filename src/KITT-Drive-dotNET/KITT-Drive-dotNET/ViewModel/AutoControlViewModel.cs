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
		private AutoControl _autoControl = new AutoControl();

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
		
		List<int> xRefList;
		List<int> tRefList;

		//private List<DataPoint> _yPoints;

		//public List<DataPoint> YPoints
		//{
		//	get { return _yPoints; }
		//	set 
		//	{
		//		_yPoints = value;
		//		RaisePropertyChanged("YPoints");
		//	}
		//}
		public List<DataPoint> YPoints
		{
			get { return AutoControl.yPoints;}
		}
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
		bool parseRefString(string s, out List<int> list)
		{
			if (String.IsNullOrEmpty(s))
			{
				list = null;
				Status = AutoControlStatus.StringEmpty;
				return false;
			}

			List<int> ints = new List<int>();
			string[] split = s.Split(' ');

			foreach (string str in split)
			{
				int parsed;
				if (!int.TryParse(str, out parsed))
				{
					list = null;
					Status = AutoControlStatus.ParseFailed;
					return false;
				}
				ints.Add(parsed);
			}

			list = ints;
			return true;
		}

		bool validateRefs()
		{
			if (!parseRefString(xRefString, out xRefList) || !parseRefString(tRefString, out tRefList))
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
		#endregion

		#region Commands
		void StartExecute()
		{
			validateRefs();
			Status = AutoControlStatus.Running;
			AutoControl.tRefList = tRefList;
			AutoControl.xRefList = xRefList;
			AutoControl.Start();
		}

		bool CanStartExecute()
		{
			if (Status == AutoControlStatus.Running)
				return false;
			else
				return validateRefs();
			//return true;
		}

		public ICommand Start { get { return new RelayCommand(StartExecute, CanStartExecute); } }
		#endregion
	}
}
