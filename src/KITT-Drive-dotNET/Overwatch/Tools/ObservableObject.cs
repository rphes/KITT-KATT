using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.CompilerServices;

namespace KITT_Drive_dotNET
{
	public abstract class ObservableObject : INotifyPropertyChanged
	{
		public event PropertyChangedEventHandler PropertyChanged;

		protected virtual void OnPropertyChanged(PropertyChangedEventArgs e)
		{
			var handler = this.PropertyChanged;
			if (handler != null)
			{
				handler(this, e);
			}
		}

		protected void RaisePropertyChanged(string propertyName)
		{
			VerifyPropertyName(propertyName);
			OnPropertyChanged(new PropertyChangedEventArgs(propertyName));
		}

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
