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
  public class AvailabilityToIconValueConverter : IValueConverter
  {

    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
      StationAvailability availability = (StationAvailability)value;
      string iconName = "";

      switch (availability)
      {
        case StationAvailability.OK:
          iconName = "Green";
          break;
        case StationAvailability.NoBikes:
          iconName = "RedEmpty";
          break;
        case StationAvailability.NoParking:
          iconName = "RedFull";
          break;
        case StationAvailability.OnlyFewBikes:
          iconName = "Yellow";
          break;
        case StationAvailability.OnlyFewParking:
          iconName = "YellowFull";
          break;
      }

      iconName = string.Format("Images/{0}Menu@2x.png", iconName);
      return iconName;
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
      throw new NotImplementedException();
    }
  }
}

