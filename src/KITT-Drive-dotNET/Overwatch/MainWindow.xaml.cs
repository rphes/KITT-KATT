using System.Windows;

namespace Overwatch
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		public MainWindow()
		{
			this.DataContext = Data.MainViewModel;
			InitializeComponent();		
		}
	}

}
