using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Windows.Controls.Primitives;

namespace Telobike.Phone
{
  public partial class StationStatusUserControl : UserControl
  {
    Station _station = null;

    public StationStatusUserControl()
    {
      InitializeComponent();
    }

    public StationStatusUserControl(Station station)
    {
      InitializeComponent();
      _station = station;
      this.DataContext = _station;
    }

    private void Button_Click(object sender, RoutedEventArgs e)
    {
      Popup buyPop = this.Parent as Popup;
      buyPop.IsOpen = false;
    }
  }
}
