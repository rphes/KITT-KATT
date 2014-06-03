namespace Overwatch.ViewModel
{
	/// <summary>
	/// Holds each independent viewmodel.
	/// </summary>
	public class MainViewModel
	{
		#region Data members
		public VehicleViewModel VehicleViewModel { get; set; }
		public CommunicationViewModel CommunicationViewModel { get; set; }
		public VisualisationViewModel VisualisationViewModel { get; set; }
		public AutoControlViewModel AutoControlViewModel { get; set; }
		#endregion

		#region Methods
		/// <summary>
		/// Initializes each viewmodel after the MainViewModel has been constructed.
		/// </summary>
		public void Init()
		{
			if (VehicleViewModel == null)
				VehicleViewModel = new VehicleViewModel();
			if (CommunicationViewModel == null)
				CommunicationViewModel = new CommunicationViewModel();
			if (VisualisationViewModel == null)
				VisualisationViewModel = new VisualisationViewModel();
			if (AutoControlViewModel == null)
				AutoControlViewModel = new AutoControlViewModel();
		}
		#endregion
	}
}
