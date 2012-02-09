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
  public class StationRawData
  {
    public int sid { get; set; }
    public string city { get; set; }
    public string name { get; set; }
    public string name_en { get; set; }
    public double latitude { get; set; }
    public double longitude { get; set; }
    public string location { get; set; }
    public int available_bike { get; set; }
    public int available_spaces { get; set; }
    public DateTime last_update { get; set; }
  }
}
