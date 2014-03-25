using OxyPlot;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace OxyPlotTest
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window, INotifyPropertyChanged
	{
		public MainWindow()
		{
			InitializeComponent();
			this.DataContext = this;
			PlotData = new ObservableCollection<DataPoint>();
		}
		private ObservableCollection<DataPoint> _plotData = new ObservableCollection<DataPoint>();

		public ObservableCollection<DataPoint> PlotData
		{
			get { return _plotData; }
			set { _plotData = value; OnPropertyChanged("PlotData"); }
		}
		
		int x = 0;

		private void Window_MouseDown(object sender, MouseButtonEventArgs e)
		{
			Random r = new Random();
			int y = r.Next(-50, 50);
			PlotData.Add(new DataPoint(x,y));
			x++;
		}

		#region binding stuff
		public event PropertyChangedEventHandler PropertyChanged;

		protected void OnPropertyChanged(string name)
		{
			PropertyChangedEventHandler handler = PropertyChanged;
			if (handler != null)
			{
				handler(this, new PropertyChangedEventArgs(name));
			}
		}
		#endregion
	}
}
