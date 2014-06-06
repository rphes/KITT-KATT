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
			Data.MainViewModel.Init();
			this.DataContext = Data.MainViewModel;
			InitializeComponent();

			Data.SrcDirectoryNotFound += Data_FindSrcDirectoryFailed;
			Data.MainViewModel.AutoControlViewModel.AutoControl.Matlab.MatlabNotFound += Data_MatlabNotFound;
		}

		void Data_FindSrcDirectoryFailed(object sender, System.EventArgs e)
		{
			// Could not find "src" directory, make errors
			MessageBox.Show("It appears you are not running Overwatch from a directory inside the project's src folder, please run it from the correct location.", "src folder not found!", MessageBoxButton.OK, MessageBoxImage.Error);
		}

		void Data_MatlabNotFound(object sender, System.EventArgs e)
		{
			MessageBox.Show("Could not find an instance of MATLAB, did you close it? \nThe program will now close.", "MATLAB not found", MessageBoxButton.OK, MessageBoxImage.Error);
			Application.Current.Shutdown();
		}
	}

}
