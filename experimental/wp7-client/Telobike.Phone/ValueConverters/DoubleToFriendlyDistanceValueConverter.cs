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
  public class DoubleToFriendlyDistanceValueConverter : IValueConverter
  {
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
      double distance = (double)value;
      if (distance < 1000.0)
      {
        int intDist = (int)distance;
        return intDist + " מטר";
      }
      else
      {
        distance = (distance / 1000.0);
        return String.Format("{0:0.0}  ק\"מ", distance);
      }
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
      throw new NotImplementedException();
    }
  }
}

