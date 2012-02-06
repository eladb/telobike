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
using System.Collections;
using System.Collections.Generic;
using System.Device.Location;

namespace Telobike.Phone
{
  public class IDistanceComparer : IComparer<GeoCoordinate>
  {
    private GeoCoordinate _origin;

    public IDistanceComparer(GeoCoordinate origin)
    {
      this._origin = origin;
    }

    public int Compare(GeoCoordinate x, GeoCoordinate y)
    {
      double distanceX = x.GetDistanceTo(this._origin);
      double distanceY = y.GetDistanceTo(this._origin);

      return distanceX.CompareTo(distanceY);
    }
  }
}
