//
//  TBListViewController.swift
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation

class TBListViewController: UITableViewController {
    private let dateFormatter = NSDateFormatter()

    var sortedStations: [TBStation] = []
    var stationsObserver: TBObserver?

    // MARK: UIViewController Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.dateStyle = .ShortStyle
        self.dateFormatter.timeStyle = .ShortStyle
        
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        
        let server = TBServer.instance
        
        self.stationsObserver = TBObserver.observerForObject(server, keyPath: "stationsUpdateTime") {
            self.sortedStations = TBServer.instance.sortStationsByDistance(TBServer.instance.stations)
            self.renderLastUpdateTime()
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        
        self.tableView.keyboardDismissMode = .OnDrag
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.startAnimating()
        self.tableView.backgroundView = activityIndicator

        let nib = UINib(nibName: "TBStationTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: STATION_CELL_REUSE_IDENTIFIER)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        TBServer.instance.reloadStations(force: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.analyticsScreenDidAppear("list")
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedStations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(STATION_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as TBStationTableViewCell
        cell.station = self.sortedStations[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let station = self.sortedStations[indexPath.row]
        let mapViewController = self.main().mapViewController
        mapViewController.selectAnnotation(station, animated: false)
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    // MARK: Operations
    
    func refresh(sender: UIRefreshControl?) {
        TBServer.instance.reloadStations(force: true)
    }
    
    func renderLastUpdateTime() {
        if let station = self.sortedStations.first as TBStation? {
            if let lastUpdate = station.lastFetchTime {
                let formattedTime = self.dateFormatter.stringFromDate(lastUpdate)
                self.refreshControl?.attributedTitle = NSAttributedString(
                    string: "Updated at \(formattedTime)",
                    attributes: [ NSForegroundColorAttributeName: UIColor.lightGrayColor() ])
            }
        }
        else {
            self.refreshControl?.attributedTitle = nil
        }
    }
}