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
using System.ComponentModel;
using System.Device.Location;

namespace Telobike.Phone
{
  public class Station : INotifyPropertyChanged
  {
    //public GeoCoordinate GetGeoCoordinate(GeoCoordinate origin)
    //{
    //  GeoCoordinate gc = new GeoCoordinate(this._latitude, this.longitude);
    //  this.DistanceFromOrigin = gc.GetDistanceTo(origin);
    //  return gc;
    //}

    private StationRawData _rawData = null;
    public Station(StationRawData stationRaw)
    {
      this._rawData = stationRaw;
      this.Availability = CalculateAvailability();
      this._Coordinate = new GeoCoordinate(this.Latitude, this.Longitude);
    }

    private GeoCoordinate _currentLocation = null;
    public void SetCurrentLocation(GeoCoordinate current)
    {
      this._currentLocation = current;
      this.DistanceFromOrigin = this.Coordinate.GetDistanceTo(this._currentLocation);
    }

    public double DistanceFromOrigin
    {
      get
      {
        return _DistanceFromOrigin;
      }
      set
      {
        if (value != _DistanceFromOrigin)
        {
          _DistanceFromOrigin = value;
          NotifyPropertyChanged("DistanceFromOrigin");
        }
      }
    }
    private double _DistanceFromOrigin = default(double);

    public GeoCoordinate Coordinate
    {
      get { return _Coordinate; }
    }
    private GeoCoordinate _Coordinate = null;

    public StationAvailability Availability
    {
      get
      {
        return _Availability;
      }
      set
      {
        if (value != _Availability)
        {
          _Availability = value;
          NotifyPropertyChanged("Availability");
        }
      }
    }
    private StationAvailability _Availability = default(StationAvailability);

    public int StationID
    {
      get { return this._rawData.sid; }
    }

    public string City
    {
      get { return this._rawData.city; }
    }

    public string Name
    {
      get { return this._rawData.name; }
    }

    public string Name_en
    {
      get { return this._rawData.name_en; }
    }

    public double Latitude
    {
      get { return this._rawData.latitude; }
    }

    public double Longitude
    {
      get { return this._rawData.longitude; }
    }

    public int BikesAvailable
    {
      get { return this._rawData.available_bike; }
    }

    public int ParkingAvailable
    {
      get { return this._rawData.available_spaces; }
    }

    public DateTime last_update
    {
      get { return this._rawData.last_update; }
    }

    private StationAvailability CalculateAvailability()
    {
      if (this.BikesAvailable == 0)
        return StationAvailability.NoBikes;
      if (this.BikesAvailable < 3)
        return StationAvailability.OnlyFewBikes;

      if (this.ParkingAvailable == 0)
        return StationAvailability.NoParking;
      if (this.ParkingAvailable < 3)
        return StationAvailability.OnlyFewParking;

      return StationAvailability.OK;
    }

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
