
//
//  MapViewController.swift
//  Feed Me
//
/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SnapKit
import GoogleMaps
import SwiftyJSON

let kMapStyle = "[{\"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#ebe3cd\"}]}, {\"elementType\": \"labels\", \"stylers\": [{\"visibility\": \"off\"}]}, {\"elementType\": \"labels.text.fill\", \"stylers\": [{\"color\": \"#523735\"}]}, {\"elementType\": \"labels.text.stroke\", \"stylers\": [{\"color\": \"#f5f1e6\"}]}, {\"featureType\": \"administrative\", \"elementType\": \"geometry.stroke\", \"stylers\": [{\"color\": \"#c9b2a6\"}]}, {\"featureType\": \"administrative.land_parcel\", \"stylers\": [{\"visibility\": \"off\"}]}, {\"featureType\": \"administrative.land_parcel\", \"elementType\": \"geometry.stroke\", \"stylers\": [{\"color\": \"#dcd2be\"}]}, {\"featureType\": \"administrative.land_parcel\", \"elementType\": \"labels.text.fill\", \"stylers\": [{\"color\": \"#ae9e90\"}]}, {\"featureType\": \"administrative.neighborhood\", \"stylers\": [{\"visibility\": \"off\"}]}, {\"featureType\": \"landscape.natural\", \"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#dfd2ae\"}]}, {\"featureType\": \"poi\", \"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#dfd2ae\"}]}, {\"featureType\": \"poi\", \"elementType\": \"labels.text.fill\", \"stylers\": [{\"color\": \"#93817c\"}]}, {\"featureType\": \"poi.park\", \"elementType\": \"geometry.fill\", \"stylers\": [{\"color\": \"#a5b076\"}]}, {\"featureType\": \"poi.park\", \"elementType\": \"labels.text.fill\", \"stylers\": [{\"color\": \"#447530\"}]}, {\"featureType\": \"road\", \"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#f5f1e6\"}]}, {\"featureType\": \"road.arterial\", \"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#fdfcf8\"}]}, {\"featureType\": \"road.highway\", \"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#f8c967\"}]}, {\"featureType\": \"road.highway\", \"elementType\": \"geometry.stroke\", \"stylers\": [{\"color\": \"#e9bc62\"}]}, {\"featureType\": \"road.highway.controlled_access\", \"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#e98d58\"}]}, {\"featureType\": \"road.highway.controlled_access\", \"elementType\": \"geometry.stroke\", \"stylers\": [{\"color\": \"#db8555\"}]}, {\"featureType\": \"road.local\", \"elementType\": \"labels.text.fill\", \"stylers\": [{\"color\": \"#806b63\"}]}, {\"featureType\": \"transit.line\", \"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#dfd2ae\"}]}, {\"featureType\": \"transit.line\", \"elementType\": \"labels.text.fill\", \"stylers\": [{\"color\": \"#8f7d77\"}]}, {\"featureType\": \"transit.line\", \"elementType\": \"labels.text.stroke\", \"stylers\": [{\"color\": \"#ebe3cd\"}]}, {\"featureType\": \"transit.station\", \"elementType\": \"geometry\", \"stylers\": [{\"color\": \"#dfd2ae\"}]}, {\"featureType\": \"water\", \"elementType\": \"geometry.fill\", \"stylers\": [{\"color\": \"#b9d3c2\"}]}, {\"featureType\": \"water\", \"elementType\": \"labels.text.fill\", \"stylers\": [{\"color\": \"#92998d\"}]}]"

class MapViewController: UIViewController {


    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
//    let dataProvider = GoogleDataProvider()
    let searchRadius: Double = 1000
    var dsSingleton : DeepStreamSingleton?
    var userLocation : Record?
    var markerNearUser : Record?
    var recordsNearUser : Array<Record> = []
    var recordsOnMap : [String : WWMarker] = [String : WWMarker]()
    
    var lastLocation : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        mapView.settings.scrollGestures = false
        mapView.settings.consumesGesturesInView = false
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = false
        // Set the map style by passing a valid JSON string.
        do {
            // Set the map style by passing a valid JSON string.
            mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        DispatchQueue.global().async {
            self.dsSingleton = DeepStreamSingleton.sharedInstance;
            self.userLocation = self.dsSingleton?.client?.record.getRecord("userlocation/" + (self.dsSingleton?.userUID)!)
            self.markerNearUser = self.dsSingleton?.client?.record.getRecord("nearuser/" + (self.dsSingleton?.userUID)!)
            self.markerNearUser?.whenReady(self)
            self.markerNearUser?.subscribe(self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let curr = locations.first {
            if let prev = self.lastLocation {
                if (curr.coordinate.latitude != prev.latitude || curr.coordinate.longitude != prev.longitude) {
                    var userLocationMarker = GMSMarker.init(position: curr.coordinate)
                    userLocationMarker.icon = "🐯".image()
                    userLocationMarker.map = self.mapView
                    mapView.camera = GMSCameraPosition(target: curr.coordinate, zoom: 15, bearing: 0, viewingAngle: 45)
                    updateDSLocation(coordinate: curr.coordinate)
                    self.lastLocation = curr.coordinate
                    
                }
            } else {
                mapView.camera = GMSCameraPosition(target: curr.coordinate, zoom:15, bearing: 0, viewingAngle: 45)
                //        locationManager.stopUpdatingLocation()
                self.lastLocation = curr.coordinate
                //sendLocation(curr.coordinate)
                
            }
        }
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        // reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            mapView.selectedMarker = nil
            
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        DispatchQueue.global().async {
            let wwMarker = marker as! WWMarker
            if let coinData = wwMarker.coinData {
                let data = ["coin" : coinData["uid"]]
                guard let rpcResponse = self.dsSingleton?.client?.rpc.make("pickup-coin", data: data.jsonElement) else {
                    print("RPC failed")
                    return
                }
                print("Subscriber: RPC success with data: \(rpcResponse.getData()!)")
            }
        }
        return true
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
}

// MARK: Segues

extension MapViewController {
    func presentMarkerViewController(marker : GMSMarker) {
        let markerViewController = self.storyboard?.instantiateViewController(withIdentifier :"MarkerViewController") as! MarkerViewController
        markerViewController.modalPresentationStyle = .overCurrentContext
        markerViewController.modalTransitionStyle = .crossDissolve
        markerViewController.preferredContentSize = CGSize(width: 200, height: 200)
        present(markerViewController, animated: true, completion: nil)
        let popoverPresentationController = markerViewController.popoverPresentationController
        popoverPresentationController?.sourceView = self.view
        popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
}

// MARK: DSClient Background Calls

extension MapViewController {
    func updateDSLocation(coordinate : CLLocationCoordinate2D) {
        self.userLocation?.set(["lat": coordinate.latitude, "lng": coordinate.longitude].jsonElement)
    }
    
    func handleGenericObjectRecord(nameArray : [String]?, record : Record) {
        print("nothing")
    }
    
    func requestRecordsNearUser(nearUser : Record) {
        DispatchQueue.global().async {
            let data = nearUser.get().dict
            let objectIds = Array(data.keys)
            for uid in objectIds {
                self.dsSingleton?.client?.record.getRecord("coins/" + uid).whenReady(self)
            }
        }
    }
    
    // Removing old markers
    func requestRecordsNearUser(data : JsonElement) {
        DispatchQueue.global().async {
            let data = data.dict
            let objectIds = Array(data.keys)
            var idsToRemove = Array(self.recordsOnMap.keys).indexedDictionary
            for (index, uid) in objectIds.enumerated() {
                self.dsSingleton?.client?.record.getRecord("coins/" + uid).whenReady(self)
                idsToRemove.removeValue(forKey: index)
            }
            DispatchQueue.main.async {
                for uid in Array(idsToRemove.values) {
                    print(uid)
                    let marker : WWMarker = self.recordsOnMap[uid]!
                    marker.map = nil
                    self.recordsOnMap.removeValue(forKey: uid)
                }
            }
        }
    }
    
}


//Keep all the uids, then any uids of not count i will be removed and discarded
// https://www.raywenderlich.com/148515/grand-central-dispatch-tutorial-swift-3-part-2
// MARK: DSClient UI Thread Calls (updates UI)
extension MapViewController {
    
    private func serializedDataToJsonObject(_ obj : Any? ) -> JsonObject {
        let data = try! JSONSerialization.data(withJSONObject: obj, options: [])
        let json = String(data: data, encoding: String.Encoding.utf8)
        return Gson().fromJson(with: json, with: JsonObject_class_()) as! JsonObject
    }
    func makePlaceMarkerFromRecord(geoRecord : Record!) {
        DispatchQueue.main.async {
            let recordData = geoRecord.get().dict
            print(recordData)
            let locationObj = self.serializedDataToJsonObject(recordData["location"])
            let coordinatesObj = self.serializedDataToJsonObject(locationObj.dict["coordinates"])
            let latLng = coordinatesObj.dict as? [String : Double]
                        let coinCoord = CLLocationCoordinate2D(latitude: (latLng?["lat"]!)!, longitude: (latLng?["lng"]!)!)
            let marker = WWMarker(coordinate: coinCoord)
            marker.map = self.mapView
            self.recordsOnMap[geoRecord.name()] = marker
        }
    }
}
// MARK: DS Client Listeners
extension MapViewController: RecordReadyListener, RecordChangedCallback {
    /*!
     @brief Called when the record is loaded from the server
     @param recordName The name of the record which is now ready
     @param record     The record which is now ready / loaded from server
     */
    public func onRecordReady(_ recordName: String!, record: Record!) {
        let recordNameArray = recordName.components(separatedBy: "/")
        switch recordNameArray[0] {
            case "nearuser":
                self.requestRecordsNearUser(nearUser: record)
            case "coins":
                self.makePlaceMarkerFromRecord(geoRecord: record)
            case "object":
                self.handleGenericObjectRecord( nameArray: recordNameArray, record: record)
            default:
                print("default do nothing:" + recordName)
        }
        
    }
    
    func onRecordChanged(_ recordName: String!, data: JsonElement!) {
        let recordNameArray = recordName.components(separatedBy: "/")
        print("here")
        switch recordNameArray[0] {
        case "nearuser":
            self.requestRecordsNearUser(data: data)
//        case "coins":
//            self.makePlaceMarkerFromRecord(geoRecord: record)
//        case "object":
//            self.handleGenericObjectRecord( nameArray: recordNameArray, record: record)
        default:
            print("default do nothing:" + recordName)
        }
    }
}

