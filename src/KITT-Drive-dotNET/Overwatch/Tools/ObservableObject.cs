using System.ComponentModel;
using System.Diagnostics;

namespace Overwatch.Tools
{
	/// <summary>
	/// Provides methods to notify the gui of any change in viewmodel data
	/// </summary>
	public abstract class ObservableObject : INotifyPropertyChanged
	{
		public event PropertyChangedEventHandler PropertyChanged;

		/// <summary>
		/// Notifies the gui of a changed property
		/// </summary>
		/// <param name="e"></param>
		protected virtual void OnPropertyChanged(PropertyChangedEventArgs e)
		{
			var handler = this.PropertyChanged;
			if (handler != null)
			{
				handler(this, e);
			}
		}

		/// <summary>
		/// Wraps the OnPropertyChanged event, to add a name verification step
		/// </summary>
		/// <param name="propertyName">The name of the changed property</param>
		protected void RaisePropertyChanged(string propertyName)
		{
			VerifyPropertyName(propertyName);
			OnPropertyChanged(new PropertyChangedEventArgs(propertyName));
		}

		/// <summary>
		/// Provides a public method to update the given data binding
		/// </summary>
		/// <param name="propertyName">The name of the binding property to update</param>
		public void UpdateBinding(string propertyName)
		{
			RaisePropertyChanged(propertyName);
		}

		/// <summary>
		/// Warns the developer if this Object does not have a public property with
		/// the specified name. This method does not exist in a Release build.
		/// </summary>
		[Conditional("DEBUG")]
		[DebuggerStepThrough]
		public void VerifyPropertyName(string propertyName)
		{
			// verify that the property name matches a real,  
			// public, instance property on this Object.
			if (TypeDescriptor.GetProperties(this)[propertyName] == null)
			{
				Debug.Fail("Invalid property name: " + propertyName);
			}
		}
	}
}
