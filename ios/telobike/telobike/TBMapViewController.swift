//
//  TBMapViewController.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/16/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

class TBMapViewController: UIViewController, MKMapViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var bottomToolbar: UIToolbar!
    private weak var backButtonItem: UIBarButtonItem!

    // station details
    @IBOutlet private weak var stationDetails: UIView!
    @IBOutlet private weak var stationAvailabilityView: TBAvailabilityView!
    @IBOutlet private weak var availabilityLabel: UILabel!
    @IBOutlet private weak var toggleStationFavoriteButton: UIBarButtonItem!
    @IBOutlet private weak var labelBackgroundView: UIView!
    @IBOutlet private weak var drawerTopConstraint: NSLayoutConstraint!

    // observers
    private var stationsObserver: TBObserver?
    private var cityObserver: TBObserver?
    private var currentStationObserver: TBObserver?
    
    private var server: TBServer { return TBServer.instance }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backButtonItem = self.navigationItem.leftBarButtonItem
        
        // observers
        
        self.stationsObserver = TBObserver.observerForObject(self.server, keyPath: "stationsUpdateTime") {
            self.reloadAnnotations()
        }
        
        self.cityObserver = TBObserver.observerForObject(self.server, keyPath: "cityUpdateTime") {
            if let center = self.server.city?.cityCenter.coordinate {
                self.setMapRegion(MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.05, 0.05)),
                    animated: true,
                    withoutDeselection: true)
            }
        }

        // map view
        let trackingBarButtonItem = MKUserTrackingBarButtonItem(mapView: self.mapView)

        var bottomToolbarItems = self.bottomToolbar.items ?? [UIBarButtonItem]()
        bottomToolbarItems.append(trackingBarButtonItem)
        self.bottomToolbar.setItems(bottomToolbarItems, animated: true)
        self.mapView.showsUserLocation = true

        self.stationAvailabilityView.alignCenter = true
        self.updateStationDetails(nil, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.server.reloadStations(force: false)
        self.showOrHideRoutesOnMap()
        if self.navigationController?.viewControllers.count > 1 {
            self.navigationItem.leftBarButtonItem = self.backButtonItem
        }
        else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.analyticsScreenDidAppear("map")
    }

    @IBAction func back(sender: AnyObject!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // - MARK: Annotations
    
    func showPlacemark(placemark: SVPlacemark?) {
        // delete any existing placemark annotations
        let placemarks = self.mapView.annotations.filter { $0.isKindOfClass(TBPlacemarkAnnotation) }
        self.mapView.removeAnnotations(placemarks)

        if let pm = placemark {
            let newAnnotation = TBPlacemarkAnnotation(placemark: pm)
            self.mapView.addAnnotation(newAnnotation)
            self.mapView.selectAnnotation(newAnnotation, animated: true)
        }
    }
    
    func deselectAllAnnotations() {
        for ann in self.mapView.annotations {
            self.mapView.deselectAnnotation(ann as MKAnnotation, animated: true)
        }
    }
    
    func selectAnnotation(annotation: MKAnnotation!, animated: Bool) {
        self.mapView.selectAnnotation(annotation, animated: animated)
    }
    
    private func reloadAnnotations() {
        // add stations that are not already defined as annoations
        let newAnnotations = NSMutableSet(array: self.server.stations)
        newAnnotations.minusSet(NSSet(array: self.mapView.annotations) as Set<NSObject>)
        self.mapView.addAnnotations(newAnnotations.allObjects as! [MKAnnotation])
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(TBPlacemarkAnnotation) {
            let placemarkReuseID = "placemark"
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier(placemarkReuseID)
            if view == nil {
                let v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: placemarkReuseID)
                view = v
                v.pinColor = .Red
                v.animatesDrop = true
                v.canShowCallout = true
            }
            
            view!.annotation = annotation
            return view
        }
        
        if annotation.isKindOfClass(TBStation) {
            let stationReuseID = "station"
            var view = self.mapView.dequeueReusableAnnotationViewWithIdentifier(stationReuseID)
            if view == nil {
                view = TBStationAnnotationView(annotation: annotation, reuseIdentifier: stationReuseID)
            }
            view!.annotation = annotation
            return view
        }
        
        return nil
    }
    
    // - MARK: Selection
    
    private func updateTitle(title: String?) {
        self.navigationItem.title = title ?? self.title
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        self.updateStationDetails(nil, animated: true)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        var annotationRegion: MKCoordinateRegion?
        
        if let stationAnnotation = view.annotation as? TBStation {
            self.updateStationDetails(stationAnnotation, animated: true)
            annotationRegion = MKCoordinateRegion(
                center: stationAnnotation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
        }
        
        if let placemarkAnnotation = view.annotation as? TBPlacemarkAnnotation {
            self.updateTitle(placemarkAnnotation.placemark.formattedAddress)
            annotationRegion = MKCoordinateRegionMakeWithDistance(placemarkAnnotation.coordinate, 1000.0, 1000.0)
        }
        
        if annotationRegion != nil {
            self.setMapRegion(annotationRegion!, animated: true, withoutDeselection: true)
        }
    }
    
    // - MARK: Map Region Changes
    
    private var avoidDeselectionWhenChangingRegion = false
    
    func setMapRegion(region: MKCoordinateRegion, animated: Bool, withoutDeselection: Bool) {
        self.avoidDeselectionWhenChangingRegion = withoutDeselection
        self.mapView.setRegion(region, animated: animated)
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // if region is changing for selection, do nothing
        if self.avoidDeselectionWhenChangingRegion { return; }
        self.deselectAllAnnotations()
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.avoidDeselectionWhenChangingRegion = false
    }
    
    // - MARK: Station Details
    
    private func openDetails(animated: Bool) {
        let f: () -> () = {
            self.drawerTopConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }
        
        if (animated) {
            UIView.animateWithDuration(0.5,
                delay: 0.0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 8.0,
                options: UIViewAnimationOptions(rawValue: 0),
                animations: f,
                completion: nil)
        }
        else {
            f()
        }
    }
    
    private func closeDetails(animated: Bool) {
        let f: () -> () = {
            self.drawerTopConstraint.constant = -self.stationDetails.frame.size.height
            self.view.layoutIfNeeded()
        }
        
        if (animated) {
            UIView.animateWithDuration(0.5,
                delay: 0.0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: -8.0,
                options: UIViewAnimationOptions(rawValue: 0),
                animations: f,
                completion: nil)
        }
        else {
            f()
        }
    }

    private var openedStation: TBStation? {
        return self.mapView.selectedAnnotations.first as? TBStation
    }
    
    private func availabilityTitleForStation(station: TBStation) -> String? {
        switch station.state {
        case .StationFull: return NSLocalizedString("No parking", comment: "")
        case .StationEmpty: return NSLocalizedString("No bicycles", comment: "")
        case .StationMarginal: return NSLocalizedString("Almost empty", comment: "")
        case .StationMarginalFull: return NSLocalizedString("Almost full", comment: "")
        case .StationInactive: return NSLocalizedString("Not operational", comment: "")
        case .StationUnknown: fallthrough
        case .StationOK: fallthrough
        default:
            return nil
        }
    }
    
    private func updateStationDetails(station: TBStation?, animated: Bool) {
        if station == nil {
            self.currentStationObserver = nil
            self.closeDetails(animated)
            self.updateTitle(nil)
            return
        }
        
        self.currentStationObserver = TBObserver.observerForObject(station, keyPath: "lastUpdateTime") {
            self.stationAvailabilityView.station = station
            let labelText = self.availabilityTitleForStation(station!)
            self.availabilityLabel.hidden = labelText == nil
            self.availabilityLabel.text = labelText
            self.availabilityLabel.textColor = station!.indicatorColor
            self.labelBackgroundView.hidden = self.availabilityLabel.hidden
        }
        
        self.openDetails(true)
        self.updateFavoriteButton(station!)
        self.updateTitle(station!.stationName)
    }
    
    private func updateFavoriteButton(station: TBStation) {
        self.toggleStationFavoriteButton.image = station.isFavorite ?
            UIImage(named: "station-favorite-selected") :
            UIImage(named: "station-favorite-unselected")
    }
    
    @IBAction private func toggleStationFavorite(sender: AnyObject!) {
        if let station = self.openedStation {
            
            // show a one-off alert with information on how favorites work
            if NSUserDefaults.standardUserDefaults().oneOff("favorites_alert_one_off") {
                TBAlerts.showAlertFromViewController(self,
                    title: NSLocalizedString("Star/Unstar Station", comment: ""),
                    message: NSLocalizedString("This station has been added to your list of favorites. Tap again to unstar", comment: ""))
            }
            
            station.favorite = !station.favorite
            self.updateFavoriteButton(station)
        }
    }
    
    @IBAction private func sendStationReport(sender: AnyObject!) {
        // gracefully bypass if city was not loaded and we don't have an email address
        if TBServer.instance.city == nil {
            return
        }
        
        if let station = self.openedStation {
            let openMailComposer: () -> () = {
                let vc = TBFeedbackMailComposeViewController(feedbackOption: TBFeedbackActionSheetService)
                vc.mailComposeDelegate = self
                vc.setSubject(NSLocalizedString("Problem in station \(station.sid)", comment: ""))
                let stationAddress = station.address ?? NSLocalizedString("N/A", comment: "")
                vc.setMessageBody(NSLocalizedString("Please describe the problem:\n\n\n=====================\nStation ID: \(station.sid)\nName: \(station.stationName)\nAddress: \(stationAddress)", comment: ""), isHTML: false)
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
            if NSUserDefaults.standardUserDefaults().oneOff("report_oneoff") {
                TBAlerts.showAlertFromViewController(self,
                    title: NSLocalizedString("Contact Customer Service", comment: ""),
                    message: NSLocalizedString("An email addressed to Telofun customer service will be opened so you can report any issues with stations or individual bicycles", comment: ""),
                    dismissed: openMailComposer)
            }
            else {
                openMailComposer()
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction private func navigateToStation(sender: AnyObject!) {
        if let station = self.openedStation {
            let dest = "\(station.coordinate.latitude),\(station.coordinate.longitude)"
            if !TBGoogleMapsRouting.routeFromAddress("", toAddress: dest) {
                TBAlerts.showAlertFromViewController(self, title: NSLocalizedString("Google Maps is not installed", comment: ""))
            }
        }
    }
    
    // - MARK: My Location
    
    func showMyLocation() {
        self.mapView.setUserTrackingMode(.Follow, animated: true)
    }

    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        print("ERROR: unable to determine user location: \(error)")
    }
    
    // - MARK: Bicycle Routes
    
    private var routesVisible: Bool = true
    private var kmlParser: KMLParser?

    private func showOrHideRoutesOnMap() {
        var showRoutes = true

        if let showBicycleRoutesValue = NSUserDefaults.standardUserDefaults().objectForKey("show_bicycle_routes") as! NSNumber? {
            showRoutes = showBicycleRoutesValue.boolValue
        }
        
        if showRoutes && !self.routesVisible {
            if self.kmlParser == nil {
                self.kmlParser = KMLParser(URL: NSBundle.mainBundle().URLForResource("routes", withExtension: "kml"))
                self.kmlParser?.parseKML()
            }
            
            self.mapView.addOverlays(self.kmlParser!.overlays as! [MKOverlay])
            self.routesVisible = true
            return
        }
        
        if !showRoutes && self.routesVisible {
            if let kmlParser = self.kmlParser {
                self.mapView.removeOverlays(kmlParser.overlays as! [MKOverlay])
            }
            self.routesVisible = false
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return (self.kmlParser?.rendererForOverlay(overlay))!
    }
}