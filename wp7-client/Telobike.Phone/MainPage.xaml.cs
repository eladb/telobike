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
using Microsoft.Phone.Controls;
using Newtonsoft.Json;
using System.Collections.ObjectModel;
using System.Device.Location;

namespace Telobike.Phone
{
  public partial class MainPage : PhoneApplicationPage
  {
    ObservableCollection<Station> _stations = new ObservableCollection<Station>();
    GeoCoordinate _currentPosition = null;

    // Constructor
    public MainPage()
    {
      InitializeComponent();
    }

    private void PhoneApplicationPage_Loaded(object sender, RoutedEventArgs e)
    {
      WebClient client = new WebClient();
      Uri uri = new Uri("http://telobike.citylifeapps.com/stations?alt=json");
      client.DownloadStringCompleted += new DownloadStringCompletedEventHandler(client_DownloadStringCompleted);
      client.DownloadStringAsync(uri);

      GeoCoordinateWatcher watcher = new GeoCoordinateWatcher(GeoPositionAccuracy.High);
      watcher.MovementThreshold = 20; // 20 meters

      watcher.Start();
      
      var myPosition = watcher.Position;
      _currentPosition = myPosition.Location;
      var latitude = myPosition.Location.Latitude.ToString();
      var longitude = myPosition.Location.Longitude.ToString();
    }

    void client_DownloadStringCompleted(object sender, DownloadStringCompletedEventArgs e)
    {
      if (e.Cancelled)
        return;

      if (e.Error == null)
      {
        Station[] stations = JsonConvert.DeserializeObject<Station[]>(e.Result);
        var sortedByDistance = stations.OrderBy(s => s.GetGeoCoordinate(_currentPosition), new IDistanceComparer(_currentPosition));
        this._stations = new ObservableCollection<Station>(sortedByDistance);

        //this._stations = ;
        this.stationsList.ItemsSource = this._stations;
      }
    }
  }
}