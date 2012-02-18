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
  public enum GoogleTileTypes
  {
    Hybrid,
    Physical,
    Street,
    Satellite,
    WaterOverlay
  }

  public class GoogleTile : Microsoft.Phone.Controls.Maps.TileSource
  {
    private int _server;
    private char _mapmode;
    private GoogleTileTypes _tiletypes;

    public GoogleTileTypes TileTypes
    {
      get { return _tiletypes; }
      set
      {
        _tiletypes = value;
        MapMode = MapModeConverter(value);
      }
    }

    public char MapMode
    {
      get { return _mapmode; }
      set { _mapmode = value; }
    }

    public int Server
    {
      get { return _server; }
      set { _server = value; }
    }

    public GoogleTile()
    {
      UriFormat = @"http://mt{0}.google.com/vt/lyrs={1}&z={2}&x={3}&y={4}&hl=iw";
      Server = 0;
    }

    public override Uri GetUri(int x, int y, int zoomLevel)
    {
      if (zoomLevel > 0)
      {
        var Url = string.Format(UriFormat, Server, MapMode, zoomLevel, x, y);
        return new Uri(Url);
      }
      return null;
    }

    private char MapModeConverter(GoogleTileTypes tiletype)
    {
      switch (tiletype)
      {
        case GoogleTileTypes.Hybrid:
          {
            return 'y';
          }
        case GoogleTileTypes.Physical:
          {
            return 't';
          }
        case GoogleTileTypes.Satellite:
          {
            return 's';
          }
        case GoogleTileTypes.Street:
          {
            return 'm';
          }
        case GoogleTileTypes.WaterOverlay:
          {
            return 'r';
          }
      }
      return ' ';
    }
  }

}
