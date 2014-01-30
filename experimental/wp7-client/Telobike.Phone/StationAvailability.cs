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

namespace Telobike.Phone
{
  /*
     * Icon colors represent the status of the station:
     * Green: everything's good
     * Red empty: no bicycle
     * Red full: no parking slots
     * Yellow empty: 3 bicycles or less
     * Yellow full: 3 parking slots or less
     */
  public enum StationAvailability
  {
    OK, // Has Bikes + Parking: Green
    NoBikes, // Red empty: no bicycle
    NoParking, // Red full: no parking slots
    OnlyFewBikes, // Yellow empty: 3 bicycles or less
    OnlyFewParking, // Yellow full: 3 parking slots or less
  }
}
