using System;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.ComponentModel;
using System.Collections.ObjectModel;
using System.Device.Location;
using Newtonsoft.Json;

namespace Telobike.Phone
{
  public class MainViewModel : INotifyPropertyChanged
  {
    public MainViewModel()
    {

    }

    public void Initialize()
    {
      _watcher.MovementThreshold = 20; // 20 meters
      _watcher.Start();
    }

    public void LoadStations()
    {
      CurrentPosition = _watcher.Position.Location;

      WebClient client = new WebClient();
      Uri uri = new Uri("http://telobike.citylifeapps.com/stations?alt=json");
      client.DownloadStringCompleted += new DownloadStringCompletedEventHandler(client_DownloadStringCompleted);
      client.DownloadStringAsync(uri);
    }

    void client_DownloadStringCompleted(object sender, DownloadStringCompletedEventArgs e)
    {
      if (e.Cancelled)
        return;

      if (e.Error == null)
      {
        StationRawData[] stations = JsonConvert.DeserializeObject<StationRawData[]>(e.Result);

        var query = (from stationRow in stations
                     select new Station(stationRow)).ToArray();

        foreach (Station station in query)
        {
          station.SetCurrentLocation(CurrentPosition);
        }

        var sortedByDistance = query.OrderBy(s => s.DistanceFromOrigin);
        this.Stations = new ObservableCollection<Station>(sortedByDistance);
        //NotifyPropertyChanged("Stations");
      }
    }

    GeoCoordinateWatcher _watcher = new GeoCoordinateWatcher(GeoPositionAccuracy.High);

    #region Property Stations
    public ObservableCollection<Station> Stations
    {
      get
      {
        return _Stations;
      }
      set
      {
        if (value != _Stations)
        {
          _Stations = value;
          NotifyPropertyChanged("Stations");
        }
      }
    }
    private ObservableCollection<Station> _Stations = null;
    #endregion
    
    #region Property CurrentPosition
    public GeoCoordinate CurrentPosition
    {
      get
      {
        return _CurrentPosition;
      }
      set
      {
        if (value != _CurrentPosition)
        {
          _CurrentPosition = value;
          NotifyPropertyChanged("CurrentPosition");
        }
      }
    }
    private GeoCoordinate _CurrentPosition = default(GeoCoordinate);
    #endregion

    public event System.ComponentModel.PropertyChangedEventHandler PropertyChanged;
    private void NotifyPropertyChanged(String propertyName)
    {
      System.ComponentModel.PropertyChangedEventHandler handler = PropertyChanged;
      if (null != handler)
      {
        handler(this, new System.ComponentModel.PropertyChangedEventArgs(propertyName));
      }
    }
  }
}
