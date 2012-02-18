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
using Microsoft.Phone.Controls.Maps;

namespace Telobike.Phone
{
  public partial class MainPage : PhoneApplicationPage
  {
    MapLayer stationsLayer;

    // Constructor
    public MainPage()
    {
      InitializeComponent();

      stationsLayer = new MapLayer();
      this.map.Children.Add(stationsLayer);

      DataContext = App.ViewModel;
      App.ViewModel.StationsSearching += new EventHandler(ViewModel_StationsSearching);
      App.ViewModel.StationsSearched += new EventHandler(ViewModel_StationsSearched);
    }

    void ViewModel_StationsSearched(object sender, EventArgs e)
    {
      Progress.IsIndeterminate = false;
      Progress.Visibility = System.Windows.Visibility.Collapsed;

      AvailabilityToIconValueConverter converter =
      this.Resources["AvailabilityToIconValueConverter"] as AvailabilityToIconValueConverter;

      foreach (Station s in App.ViewModel.Stations)
      {
        string iconName = (string)converter.Convert(s.Availability, null, null, null);
        iconName = iconName.Replace("Menu", "");
        //iconName = iconName.Replace("@2x", "");

        Image pinImage = new Image();
        pinImage.Source = new System.Windows.Media.Imaging.BitmapImage(new Uri(iconName, UriKind.Relative));
        pinImage.Opacity = 0.8;
        pinImage.Stretch = System.Windows.Media.Stretch.None;
        PositionOrigin position = PositionOrigin.Center;
        pinImage.Tag = s;
        stationsLayer.AddChild(pinImage, s.Coordinate, position);
        pinImage.MouseLeftButtonDown += new MouseButtonEventHandler(pinImage_MouseLeftButtonDown);
      }
    }

    void pinImage_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
    {
      Image i = (Image)sender;
      Station s = (Station)i.Tag;
      this.map.Center = s.Coordinate;            
    }

    void ViewModel_StationsSearching(object sender, EventArgs e)
    {
      Progress.IsIndeterminate = true;
      Progress.Visibility = System.Windows.Visibility.Visible;
    }

    private void PhoneApplicationPage_Loaded(object sender, RoutedEventArgs e)
    {
      // Start the progress bar

      App.ViewModel.LoadStations();

      this.map.Center = App.ViewModel.CurrentPosition;

      Image pinImage = new Image();
      pinImage.Source = new System.Windows.Media.Imaging.BitmapImage(new Uri("Images/MyLocation@2x.png", UriKind.Relative));
      pinImage.Opacity = 0.8;
      pinImage.Stretch = System.Windows.Media.Stretch.None;
      PositionOrigin position = PositionOrigin.Center;
      stationsLayer.AddChild(pinImage, App.ViewModel.CurrentPosition, position);
    }

    private void stationsList_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
      if (e.AddedItems.Count > 0)
      {
        Station selectedStation = (Station)e.AddedItems[0];
        App.ViewModel.MapCenter = selectedStation.Coordinate;
        this.map.Center = selectedStation.Coordinate;

        // Switch to the map pivot item
        this.pivot.SelectedIndex = 0;
      }
    }
  }
}