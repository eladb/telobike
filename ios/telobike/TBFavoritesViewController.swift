//
//  TBFavoritesViewController.swift
//  telobike
//
//  Created by Amit Attias on 10/15/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import UIKit

class TBFavoritesViewController: UITableViewController {
    
    private var favoriteStations: [TBStation]!
    private var emptyLabel: UIView!
    private var stationsObserver: TBObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TBStationTableViewCell", bundle: nil) // change string to class name
        self.tableView.registerNib(nib, forCellReuseIdentifier: STATION_CELL_REUSE_IDENTIFIER)
        
        self.stationsObserver = TBObserver.observerForObject(TBServer.instance, keyPath: "stationsUpdateTime") {
            self.updateFavoritesWithReload(true)
            self.refreshControl?.endRefreshing()
        }
        
        self.emptyLabel = NSBundle.mainBundle().loadNibNamed("NoFavoritesView", owner: nil, options: nil)[0] as UIView
        self.tableView.backgroundView = self.emptyLabel;
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateFavoritesWithReload(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.analyticsScreenDidAppear("favorites")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Data
    
    @IBAction func refresh(sender: UIRefreshControl) {
        TBServer.instance.reloadStations {}
    }

    func updateFavoritesWithReload(reload:Bool) {
        let favorites = TBServer.instance.stations.filter() {
            return $0.isFavorite
        }
        
        self.favoriteStations = TBServer.instance.sortStationsByDistance(favorites)
        
        self.emptyLabel.hidden = self.favoriteStations.count > 0;
        
        self.tableView.scrollEnabled = self.emptyLabel.hidden;
        
        if (reload) {
            self.tableView.reloadData()
        }
    }
    

    // MARK: Table view
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteStations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(STATION_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as TBStationTableViewCell
        
        cell.station = self.favoriteStations[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var mapViewContoller = self.main().mapViewController
        mapViewContoller.selectAnnotation(self.favoriteStations[indexPath.row] as TBStation, animated: false)
        self.navigationController?.pushViewController(mapViewContoller, animated: true)
    }
    
    // MARK: Swipe to remove
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            self.favoriteStations[indexPath.row].favorite = false
            
            self.updateFavoritesWithReload(false)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            tableView.endUpdates()
            return
        }
    }
}
