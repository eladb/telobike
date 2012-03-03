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
using System.Windows.Controls.Primitives;
using System.IO.IsolatedStorage;
using Microsoft.Phone.Tasks;

namespace Telobike.Phone
{
  public partial class MainPage : PhoneApplicationPage
  {
    MapLayer stationsLayer;
    MapLayer selectedStationLayer;
    Popup buyNowScreen;
    StationStatusUserControl stationStatus;

    // Constructor
    public MainPage()
    {
      InitializeComponent();

      stationsLayer = new MapLayer();
      this.map.Children.Add(stationsLayer);
      selectedStationLayer = new MapLayer();
      this.map.Children.Add(selectedStationLayer);

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
      SelectStationOnMap(s);
    }

    void SelectStationOnMap(Station selectedStation)
    {
      App.ViewModel.MapCenter = selectedStation.Coordinate;
      this.map.Center = selectedStation.Coordinate;

      // Show a background behind the selected station
      selectedStationLayer.Children.Clear();
      Image selectedStationBackgroundImage = new Image();
      selectedStationBackgroundImage.Source = new System.Windows.Media.Imaging.BitmapImage(new Uri("Images/SelectedMarker@2x.png", UriKind.Relative));
      selectedStationBackgroundImage.Opacity = 0.8;
      selectedStationBackgroundImage.Stretch = System.Windows.Media.Stretch.None;
      PositionOrigin position = PositionOrigin.Center;
      selectedStationLayer.AddChild(selectedStationBackgroundImage, selectedStation.Coordinate, position);


      GeneralTransform gt = this.TransformToVisual(this.map as UIElement);
      Point offset = gt.Transform(new Point(0, 0));
      double controlTop = offset.Y;
      double controlLeft = offset.X;

      // Show Popup
      if (stationStatus == null)
      {
        stationStatus = new StationStatusUserControl(selectedStation);
        buyNowScreen = new Popup();
        buyNowScreen.Child = stationStatus;
        buyNowScreen.IsOpen = true;
        buyNowScreen.VerticalOffset = controlTop * (-1) + 30;
        buyNowScreen.HorizontalOffset = (this.LayoutRoot.ActualWidth + controlLeft - stationStatus.Width) / 2;
        buyNowScreen.Closed += (s1, e1) =>
        {
          // Add you code here to do something
          // when the Popup is closed
        };
      }
      else
      {
        stationStatus.DataContext = selectedStation;
        buyNowScreen.IsOpen = true;
      }
    }

    void ViewModel_StationsSearching(object sender, EventArgs e)
    {
      Progress.IsIndeterminate = true;
      Progress.Visibility = System.Windows.Visibility.Visible;
    }

    private void PhoneApplicationPage_Loaded(object sender, RoutedEventArgs e)
    {
      ShowLocationPopup();

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

    private void ShowLocationPopup()
    {
      // Show the popup only if the user has not confirmed the use
      if (!App.ViewModel.UseLocationServices)
      {
        Popup locationServicesPopup = new Popup();

        LocationServicesPopup popupContent = new LocationServicesPopup();
        locationServicesPopup = new Popup();
        locationServicesPopup.Opacity = 1.0;
        locationServicesPopup.VerticalOffset = 0;
        locationServicesPopup.HorizontalOffset = 0;
        locationServicesPopup.Child = popupContent;
        locationServicesPopup.IsOpen = true;
        locationServicesPopup.Closed += (s1, e1) =>
        {
          // Add you code here to do something
          // when the Popup is closed
        };
      }
    }

    private void stationsList_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
      if (e.AddedItems.Count > 0)
      {
        // Switch to the map pivot item
        this.pivot.SelectedIndex = 0;

        Station selectedStation = (Station)e.AddedItems[0];
        SelectStationOnMap(selectedStation);
      }
    }

    private void pivot_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
      if (buyNowScreen != null && buyNowScreen.IsOpen == true)
      {
        buyNowScreen.IsOpen = false;
      }
    }

    private void mailToDeveloper_Tap(object sender, GestureEventArgs e)
    {
      new EmailComposeTask { 
          Subject = "Privacy Qeustion",
          To = "bursteg@hotmail.com"
      }.Show();
    }
  }
}