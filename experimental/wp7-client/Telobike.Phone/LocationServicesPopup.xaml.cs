using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Windows.Controls.Primitives;
using System.IO.IsolatedStorage;

namespace Telobike.Phone
{
  public partial class LocationServicesPopup : UserControl
  {
    public LocationServicesPopup()
    {
      InitializeComponent();
    }

    private void Button_Click(object sender, RoutedEventArgs e)
    {
      App.ViewModel.UseLocationServices = true;

      Popup buyPop = this.Parent as Popup;
      buyPop.IsOpen = false;
    }
  }
}
