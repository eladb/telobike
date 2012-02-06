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
    public GeoCoordinate GetGeoCoordinate(GeoCoordinate origin)
    {
      GeoCoordinate gc = new GeoCoordinate(this._latitude, this.longitude);
      this.DistanceFromOrigin = gc.GetDistanceTo(origin);
      return gc;
    }

    public double DistanceFromOrigin { get; set; }


    public int sid
    {
      get
      {
        return _sid;
      }
      set
      {
        if (value != _sid)
        {
          _sid = value;
          NotifyPropertyChanged("sid");
        }
      }
    }
    private int _sid = default(int);

    public string city
    {
      get
      {
        return _city;
      }
      set
      {
        if (value != _city)
        {
          _city = value;
          NotifyPropertyChanged("city");
        }
      }
    }
    private string _city = default(string);
    
    public string name
    {
      get
      {
        return _name;
      }
      set
      {
        if (value != _name)
        {
          _name = value;
          NotifyPropertyChanged("name");
        }
      }
    }
    private string _name = default(string);

    public string name_en
    {
      get
      {
        return _name_en;
      }
      set
      {
        if (value != _name_en)
        {
          _name_en = value;
          NotifyPropertyChanged("name_en");
        }
      }
    }
    private string _name_en = default(string);

    public double latitude
    {
      get
      {
        return _latitude;
      }
      set
      {
        if (value != _latitude)
        {
          _latitude = value;
          NotifyPropertyChanged("latitude");
        }
      }
    }
    private double _latitude = default(double);

    public double longitude
    {
      get
      {
        return _longitude;
      }
      set
      {
        if (value != _longitude)
        {
          _longitude = value;
          NotifyPropertyChanged("longitude");
        }
      }
    }
    private double _longitude = default(double);

    public string location
    {
      get
      {
        return _location;
      }
      set
      {
        if (value != _location)
        {
          _location = value;
          NotifyPropertyChanged("location");
        }
      }
    }
    private string _location = default(string);

    public int available_bike
    {
      get
      {
        return _available_bike;
      }
      set
      {
        if (value != _available_bike)
        {
          _available_bike = value;
          NotifyPropertyChanged("available_bike");
        }
      }
    }
    private int _available_bike = default(int);

    public int available_spaces
    {
      get
      {
        return _available_spaces;
      }
      set
      {
        if (value != _available_spaces)
        {
          _available_spaces = value;
          NotifyPropertyChanged("available_spaces");
        }
      }
    }
    private int _available_spaces = default(int);

    public DateTime last_update
    {
      get
      {
        return _last_update;
      }
      set
      {
        if (value != _last_update)
        {
          _last_update = value;
          NotifyPropertyChanged("last_update");
        }
      }
    }
    private DateTime _last_update = default(DateTime);

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
