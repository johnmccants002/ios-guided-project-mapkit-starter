//
//  EarthquakesViewController.swift
//  Quakes
//
//  Created by Paul Solt on 10/3/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import MapKit

class EarthquakesViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    private var userTrackingButton : MKUserTrackingButton!
    private let locationManager = CLLocationManager()
    var quakes : [Quake] = [] {
        didSet {
            let oldQuakes = Set(oldValue)
            let newQuakes = Set(quakes)
            let addedQuakes = newQuakes.subtracting(oldQuakes)
            let removedQuakes = oldQuakes.subtracting(newQuakes)
            
            mapView.removeAnnotation(Array(removedQuakes))
            mapView.addAnnotations(Array(addedQuakes))
        }
    }
    private let quakeFetcher = QuakeFetcher()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTrackingButton)
        
        NSLayoutConstraint.activate([userTrackingButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            mapView.bottomAnchor.constraint(equalTo: userTrackingButton.bottomAnchor, constant: 20)])
        
        fetchQuakes()
    }
    
    private var isCurrentlyFetchingQuakes = false
    
    private func fetchQuakes() {
        
        guard !isCurrentlyFetchingQuakes else {
            return
        }
        isCurrentlyFetchingQuakes = true
        let visibleRegion = mapView.visibleMapRect
        
        quakeFetcher.fetchQuakes(in: visibleRegion) { (quakes, error) in
            self.isCurrentlyFetchingQuakes = false
            if let error = error {
                NSLog("Error fetching quakes: \(error)")
            }
            self.quakes = quakes ?? []
        }
    }
}

extension EarthquakesViewController: MKMapViewDelegate {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        fetchQuakes()
    }
}
