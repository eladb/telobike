using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Windows.Data;
using System.Globalization;

namespace Telobike.Phone
{
  public class AvailabilityToPanelColorValueConverter : IValueConverter
  {
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
      int availability = (int)value;
      string iconName = "";

      if (availability <= 0)
        iconName = "red";
      else if (availability < 3)
        iconName = "yellow";
      else
        iconName = "green";

      iconName = string.Format("Images/{0}box.png", iconName);
      return iconName;
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
      throw new NotImplementedException();
    }
  }
}

