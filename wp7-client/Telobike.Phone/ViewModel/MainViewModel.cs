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
using System.Windows.Data;

namespace Telobike.Phone
{
  public class MainViewModel : INotifyPropertyChanged
  {
    public MainViewModel()
    {
      // Start with Tel Aviv
      this.CurrentPosition = new GeoCoordinate(latitude: 32.06777, longitude: 34.76472);
    }

    public void Initialize()
    {
      _watcher.MovementThreshold = 20; // 20 meters
      _watcher.PositionChanged += new EventHandler<GeoPositionChangedEventArgs<GeoCoordinate>>(_watcher_PositionChanged);
      _watcher.Start();
    }

    void _watcher_PositionChanged(object sender, GeoPositionChangedEventArgs<GeoCoordinate> e)
    {
      if (!e.Position.Location.IsUnknown)
      {
        //this.CurrentPosition = e.Position.Location;
      }
    }

    public void LoadStations()
    {
      CurrentPosition = _watcher.Position.Location;
      MapCenter = CurrentPosition;

      // Raise the StationsSearching
      if (StationsSearching != null)
        StationsSearching(null, EventArgs.Empty);

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

        var sortedByDistance = query; //.OrderBy(s => s.DistanceFromOrigin);
        this.Stations = new ObservableCollection<Station>(sortedByDistance);
        this.StationsView.SortDescriptions.Add(new SortDescription("DistanceFromOrigin", ListSortDirection.Descending));
        //NotifyPropertyChanged("Stations");

        // Raise the StationsSearching
        if (StationsSearched != null)
          StationsSearched(null, EventArgs.Empty);
      }
    }

    GeoCoordinateWatcher _watcher = new GeoCoordinateWatcher(GeoPositionAccuracy.High);

    #region Property StationsView
    public CollectionViewSource StationsView
    {
      get
      {
        return _StationsView;
      }
    }
    private CollectionViewSource _StationsView = new CollectionViewSource();
    #endregion

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
          this.StationsView.Source = _Stations;
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

    #region Property MapCenter
    public GeoCoordinate MapCenter
    {
      get
      {
        return _MapCenter;
      }
      set
      {
        if (value != _MapCenter)
        {
          _MapCenter = value;
          NotifyPropertyChanged("MapCenter");
        }
      }
    }
    private GeoCoordinate _MapCenter = default(GeoCoordinate);
    #endregion

    public event EventHandler StationsSearching;
    public event EventHandler StationsSearched;

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
