
//
//  GameMapViewController.swift
//

import UIKit
import SnapKit
import GoogleMaps
import SwiftyJSON

let kMapStyle = "[ { \"elementType\": \"labels\", \"stylers\": [ {  \"visibility\": \"off\" } ] }, { \"featureType\": \"administrative.land_parcel\", \"stylers\": [ {  \"visibility\": \"off\" } ] }, { \"featureType\": \"administrative.neighborhood\", \"stylers\": [ {  \"visibility\": \"off\" } ] } ]"

class GameMapViewController: UIViewController {
    
    @IBOutlet var locationArrow: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let searchRadius: Double = 1000
    var dsSingleton : DeepStreamSingleton?
    var userLocation : Record?
    var markerNearUser : Record?
    var recordsSubscribed : [String: Record] = [String : Record]()
    var recordsOnMap : [String : WWMarker] = [String : WWMarker]()
    var userLocationMarker: GMSMarker?
    var compass: GeoPointCompass?
    var lastAngleFromNorth : CLLocationDirection = Double(180)
    var mapBearing : CLLocationDegrees?
    var blueBoxView: UIImageView?
    var lastLocation : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        
        mapView.delegate = self
        mapView.settings.scrollGestures = true
        mapView.settings.rotateGestures = true
        mapView.settings.consumesGesturesInView = true
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = false
        mapView.isMyLocationEnabled = false
        mapView.addSubview(self.locationArrow)
        mapView.isBuildingsEnabled = false
        self.compass = GeoPointCompass()
        self.userLocationMarker = GMSMarker.init(position: (locationManager.location?.coordinate)!)
        if let currLocation = self.userLocationMarker {
            currLocation.iconView = UIImageView.init(image: "🐯".image())
            currLocation.tracksViewChanges = false
            currLocation.map = self.mapView
            self.compass?.arrowImageView = currLocation.iconView
        }
        // Set the map style by passing a valid JSON string.
        do {
            // Set the map style by passing a valid JSON string.
            mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        blueBoxView = UIImageView.init(image: UIImage.circle(diameter: 100, color: UIColor.blue))
        mapView.addSubview(blueBoxView!)
        
        DispatchQueue.global().async {
            self.dsSingleton = DeepStreamSingleton.sharedInstance;
            self.userLocation = self.dsSingleton?.client?.record.getRecord("userlocation/" + (self.dsSingleton?.userUID)!)
            self.markerNearUser = self.dsSingleton?.client?.record.getRecord("nearuser/" + (self.dsSingleton?.userUID)!)
            self.markerNearUser?.whenReady(self)
            self.markerNearUser?.subscribe(self)
            self.dsSingleton?.userRecord?.whenReady(self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

// MARK: - CLLocationManagerDelegate
extension GameMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        self.blueBoxView?.center = transform(bearing: newHeading.trueHeading, frame: self.mapView.frame)
    
    }
    
    func transform(bearing : CLLocationDirection, frame : CGRect ) -> CGPoint {
        print(bearing)
        if (( bearing >= 0 && bearing < 45) ||  (bearing <= 360 && bearing > 315)) {
            if (bearing > 315) {
                return CGPoint(x: frame.size.width / 2 * CGFloat((bearing - 315)) / 45.0, y: 0)
            } else {
                return CGPoint(x: frame.size.width - (frame.size.width / 2 * (1 - CGFloat((bearing)) / 45.0)), y: 0)
            }
        } else if (bearing >= 45 && bearing < 135) {
            return CGPoint(x: frame.size.width, y: (frame.size.height) * CGFloat((bearing - 45)) / 90.0)

        } else if (bearing >= 135 && bearing < 225) {
            return CGPoint(x: frame.size.width * (1 - CGFloat((bearing - 135)) / 90.0), y: frame.size.height)

        } else {
            return CGPoint(x: 0, y: (frame.size.height) * (1.0  - CGFloat((bearing - 225)) / 90.0))

        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let curr = locations.first {
            if let prev = self.lastLocation {
                if (curr.coordinate.latitude != prev.latitude || curr.coordinate.longitude != prev.longitude) {
                    if let currLocation = self.userLocationMarker {
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(1.0)
                        currLocation.position =  curr.coordinate
                        CATransaction.commit()
                        
                    }
                    mapView.camera = GMSCameraPosition(target: curr.coordinate, zoom:20, bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle)
                    updateDSLocation(coordinate: curr.coordinate)
                    self.lastLocation = curr.coordinate
                    
                }
            } else {
                mapView.camera = GMSCameraPosition(target: curr.coordinate, zoom:20, bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle)
                //        locationManager.stopUpdatingLocation()
                self.lastLocation = curr.coordinate
                //sendLocation(curr.coordinate)
                
            }
        }
    }
}

// MARK: - GMSMapViewDelegate
extension GameMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        DispatchQueue.global().async {
            
            let wwMarker = marker as! WWMarker
            print("trying to pick up")
            if let coinData = wwMarker.coinData {
                let data = ["coin" : coinData["uid"]]
                print(data)
                guard let rpcResponse = self.dsSingleton?.client?.rpc.make("pickup-coin", data: data.jsonElement) else {
                    print("RPC failed")
                    return
                }
                print("Subscriber: RPC success with data: \(rpcResponse.getData()!)")
            }
        }
        return true
    }
}

// MARK: Segues
extension GameMapViewController {
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

extension GameMapViewController {
    func updateDSLocation(coordinate : CLLocationCoordinate2D) {
        self.userLocation?.set(["lat": coordinate.latitude, "lng": coordinate.longitude].jsonElement)
    }
    
    func requestRecordsNearUser(nearUser : Record) {
        DispatchQueue.global().async {
            let data = nearUser.get().dict
            let objectIds = Array(data.keys)
            for uid in objectIds {
                self.dsSingleton?.client?.record.getRecord("object/" + uid).whenReady(self)
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
                self.dsSingleton?.client?.record.getRecord("object/" + uid).whenReady(self)
                idsToRemove.removeValue(forKey: index)
            }
            DispatchQueue.main.async {
                for uid in Array(idsToRemove.values) {
                    self.removeOldMarker(uid: uid)
                }
            }
        }
    }
    
    func removeOldMarker( uid: String ) {
        let marker : WWMarker = self.recordsOnMap[uid]!
        marker.map = nil
        self.recordsOnMap.removeValue(forKey: uid)?.record?.discard()
    }
    
}




//Keep all the uids, then any uids of not count i will be removed and discarded
// https://www.raywenderlich.com/148515/grand-central-dispatch-tutorial-swift-3-part-2
// MARK: DSClient UI Thread Calls (updates UI)
extension GameMapViewController {

    func makePlaceMarkerFromRecord(uid : String, geoRecord : Record!) {
        DispatchQueue.main.async {
            
            let recordData = geoRecord.get().deepDict
            if let locationObj = recordData["location"] as? [String : Any?] {
                if let latLng = locationObj["coordinates"] as? [String : Double] {
                    let coinCoord = CLLocationCoordinate2D(latitude: latLng["lat"]!, longitude: latLng["lng"]!)
                    let type = recordData["type"] as? String!
                    let hex = recordData["color"] as? String!
                    let marker = type == "coin" ? WWCoinMarker(coordinate: coinCoord) : WWCrumbMarker(coordinate: coinCoord, hex: hex!)
                    marker.record = geoRecord
                    marker.coinData = ["uid" : uid]
                    marker.map = self.mapView
                    self.recordsOnMap[geoRecord.name()] = marker
                    geoRecord.subscribe("owner", recordPathChangedCallback: self, triggerNow: false)
                    self.recordsSubscribed["owner"] = geoRecord
                }
            }
        }
    }
}
// MARK: DS Client Listeners
extension GameMapViewController: RecordReadyListener, RecordChangedCallback, RecordPathChangedCallback {
    /*!
     @brief Called when the listener is added via <code>Record.subscribe(String,RecordPathChangedCallback,boolean)</code><br/>
     Will contain the data under the path, regardless of whether triggered by a Patch or Update
     @param recordName The name of the record change
     @param path The path subscribed to
     @param data The data under the path as an Object
     */
    public func onRecordPathChanged(_ recordName: String!, path: String!, data: JsonElement!) {
        let recordNameArray = recordName.components(separatedBy: "/")
        let recordPrefix = recordNameArray[0]
        if (recordPrefix == "object") {
            if (path == "owner") {
                DispatchQueue.main.async {
                    self.removeOldMarker(uid : recordName)
                }
                
            }
        }
     }

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
            case "object":
                self.makePlaceMarkerFromRecord(uid : recordNameArray[1], geoRecord: record)
            default:
                print("default do nothing:" + recordName)
        }
        
    }
    
    func onRecordChanged(_ recordName: String!, data: JsonElement!) {
        let recordNameArray = recordName.components(separatedBy: "/")
        switch recordNameArray[0] {
        case "nearuser":
            self.requestRecordsNearUser(data: data)
        case "object":
            self.removeOldMarker(uid : recordNameArray[1])
        default:
            print("default do nothing:" + recordName)
        }
    }
}

