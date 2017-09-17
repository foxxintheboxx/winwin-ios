//
//  MapViewController.swift
//  WinWin
//
//  Created by Ian Fox on 3/29/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//
//
import GoogleMaps


class MapViewController: UIViewController {
    
    func setupGMSMapSettings(_ mapView: GMSMapView) {
        mapView.settings.scrollGestures = false
        mapView.settings.rotateGestures = true
        mapView.settings.consumesGesturesInView = false
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = false
        mapView.isMyLocationEnabled = false
        mapView.isBuildingsEnabled = false
        // Set the map style by passing a valid JSON string.
        do {
            // Set the map style by passing a valid JSON string.
            mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
    }

}


