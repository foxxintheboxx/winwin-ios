
//
//  GameMapViewController.swift
//

import UIKit
import SnapKit
import GoogleMaps
import SwiftyJSON
import Pulsator


class GameMapViewController: MapViewController, RadarViewControllerDelegate {

    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var dsSingleton : DeepStreamSingleton?
    var userLocation : Record?
    var markerNearUser : Record?
    var recordsSubscribed : [String: Record] = [String : Record]()
    var recordsOnMap : [String : WWMarker] = [String : WWMarker]()
    var recordsOnRadar : [String : UIImageView?] = [String : UIImageView?]()
    var userLocationMarker: GMSMarker?
    var usingRadar : Bool = false
    var bearing: CLLocationDegrees = 360.0
    var camera: GMSMutableCameraPosition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self

        self.setupGMSMapSettings(mapView)
        self.userLocationMarker = GMSMarker.init(position: (locationManager.location?.coordinate)!)
        if let currLocation = self.userLocationMarker {
            let coordinates = (locationManager.location?.coordinate)!
            currLocation.icon = "🐯".image(width: 60.0, height: 60.0, fontSize: 60.0)
            currLocation.tracksViewChanges = false
            camera = GMSMutableCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: Float(kMapZoom))
            mapView.camera = camera!
            currLocation.map = self.mapView
        }
        
        DispatchQueue.global().async {
            self.dsSingleton = DeepStreamSingleton.sharedInstance;
            self.userLocation = self.dsSingleton?.client?.record.getRecord("userlocation/" + (self.dsSingleton?.userUID)!)
            self.markerNearUser = self.dsSingleton?.client?.record.getRecord("nearuser/" + (self.dsSingleton?.userUID)!)
            self.markerNearUser?.whenReady(self)
            self.markerNearUser?.subscribe(self)
            self.dsSingleton?.userRecord?.whenReady(self)
        }
    }

    func toggleRadar(_ useRadar: Bool) {
        usingRadar = useRadar
        if useRadar {
            locationManager.startUpdatingHeading()
        } else {
            locationManager.stopUpdatingHeading()
        }
        for view in Array(self.recordsOnRadar.values) {
            view?.isHidden = !useRadar;
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension GameMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        self.bearing = newHeading.trueHeading
        let camera = GMSCameraPosition.camera(
            withLatitude: mapView.camera.target.latitude,
            longitude: mapView.camera.target.longitude,
            zoom: mapView.camera.zoom,
            bearing: self.bearing,
            viewingAngle: mapView.camera.viewingAngle
        )
        mapView.animate(with: GMSCameraUpdate.setCamera(camera))
        for (uid, coinView) in Array(self.recordsOnRadar) {
            if let userLocation = self.locationManager.location {
                if let view = coinView {
                    let marker = self.recordsOnMap[uid]
                    let angle = userLocation.coordinate.calculateAngle(location: (marker?.position)!)
                    var bearing = angle - Double(newHeading.magneticHeading)
                    let relativeCenter = 360.0 - angle
                    bearing += relativeCenter
                    let bearingBounds = CGPoint.calculateQuartileBounds(center: Int(relativeCenter))
                    view.center = CGPoint.transform(
                        bearing: Float(bearing),
                        frame: mapView.frame,
                        bounds: bearingBounds
                    )
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let curr = self.locationManager.location {
            if let currLocation = self.userLocationMarker {
                currLocation.position =  curr.coordinate
                let lat = curr.coordinate.latitude
                let lng = curr.coordinate.longitude
                let camera = GMSCameraPosition.camera(
                    withLatitude: lat,
                    longitude: lng,
                    zoom: mapView.camera.zoom,
                    bearing: self.bearing,
                    viewingAngle: mapView.camera.viewingAngle
                )
                mapView.animate(with: GMSCameraUpdate.setCamera(camera))
                updateDSLocation(coordinate: curr.coordinate)
                let visibleRegion = mapView.projection.visibleRegion()
                let mapVisibleBounds = GMSCoordinateBounds.init(region: visibleRegion)
                for (uid, marker) in Array(recordsOnMap) {
                    if let view = recordsOnRadar[uid] {
                        let hide = mapVisibleBounds.contains(marker.position)
                        self.hideRadarCoinView(coin: view!, hide: hide)
                    }
                }
            }
        }
    }
}

// MARK: - GMSMapViewDelegate
extension GameMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        DispatchQueue.global().async {
            let wwMarker = marker as! WWMarker
            if let coinData = wwMarker.coinData {
                let data = ["object" : coinData["uid"]]
                print("IANWOX " + String(describing: data))
                guard let rpcResponse = self.dsSingleton?.client?.rpc.make("pickup-object", data: data.jsonElement) else {
                    print("RPC failed")
                    return
                }
                print(rpcResponse.getData())
            }
        }
        return true
    }
}

// MARK: DSClient Background Calls
extension GameMapViewController {
    func updateDSLocation(coordinate : CLLocationCoordinate2D) {
        print("setting")
        self.userLocation?.set(["lat": coordinate.latitude, "lng": coordinate.longitude].jsonElement)
    }
    
    func requestRecordsNearUser(nearUser : Record) {
        DispatchQueue.global().async {
            let data = nearUser.get().deepDict
            let objectNames = Array(data.keys)
            for name in objectNames {
                self.dsSingleton?.client?.record.getRecord(name).whenReady(self)
            }
        }
    }
    
    // Removing old markers
    func requestRecordsNearUser(data : JsonElement) {
        DispatchQueue.global().async {
            let data = data.deepDict
            print("IANFOX " + String(data.count))
            let objectNames = Array(data.keys)
            print("IANFOX " + String(describing: objectNames))
            var idsToRemove = Array(self.recordsOnMap.keys).indexedDictionary
            for name in objectNames {
                self.dsSingleton?.client?.record.getRecord(name).whenReady(self)
                idsToRemove.removeValue(forKey: name)
            }
            for name in Array(idsToRemove.values) {
                print("IANFOX " + String(describing: data[name]))
                self.removeOldMarker(name: name)
            }
        }

    }
    
    func removeOldMarker( name: String ) {
        let markerOpt : WWMarker? = self.recordsOnMap[name] as WWMarker?
        print("IANFOX " + name)
        if let marker = markerOpt {
            let origin = mapView.projection.point(for: marker.position)
            marker.map = nil
            DispatchQueue.main.async {
                let data = marker.record?.get().deepDict
                let owner = data?["owner"] as! String?
                if (owner == self.dsSingleton?.userUID) {
                    let labelRect = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 150, height: 50))
                    let label = UILabel.init(frame: labelRect)
                    label.center = CGPoint.init(x: origin.x, y: origin.y - 20)
                    label.textAlignment = NSTextAlignment.center
                    let font = UIFont.init(name: "GillSans-Bold", size: 50.0)
                    label.font = font
                    label.textColor = UIColor.init(hexString: "daa520")
                    if let val = data?["value"] {
                        let intVal = val as! Int
                        label.text = "\(intVal)"
                    }
                    self.mapView.addSubview(label)
                    UIView.animate(withDuration: 0.8, animations: {
                        label.alpha = 0.0
                        label.center = CGPoint.init(x: label.center.x, y: label.center.y - 75)
                    }, completion:
                        { (finished: Bool) in
                            label.removeFromSuperview()
                    })
                }
            }
            self.recordsOnRadar.removeValue(forKey: name)??.removeFromSuperview()
            self.recordsOnMap.removeValue(forKey: name)?.record?.discard()
        }
    }
    
    func hideRadarCoinView(coin: UIView, hide: Bool) {
        if !self.usingRadar || hide {
            coin.isHidden = true
        } else {
            coin.isHidden = false
        }
    }
    
}

//Keep all the uids, then any uids of not count i will be removed and discarded
// https://www.raywenderlich.com/148515/grand-central-dispatch-tutorial-swift-3-part-2
// MARK: DSClient UI Thread Calls (updates UI)
extension GameMapViewController {

    func makePlaceMarkerFromRecord(uid : String, geoRecord : Record!) {
        let recordData = geoRecord.get().deepDict
        if let locationObj = recordData["location"] as? [String : Any?] {
            if let latLng = locationObj["coordinates"] as? [String : Double] {
                if self.recordsOnMap[geoRecord.name()] == nil {
                    let coinCoord = CLLocationCoordinate2D(latitude: latLng["lat"]!, longitude: latLng["lng"]!)
                    let type = recordData["type"] as? String!
                    let hex = recordData["color"] as? String!
                    geoRecord.subscribe("owner", recordPathChangedCallback: self, triggerNow: false)
                    self.recordsSubscribed["owner"] = geoRecord
                    DispatchQueue.main.async {
                        let marker = type == "coin" ? WWCoinMarker(coordinate: coinCoord) : WWCrumbMarker(coordinate: coinCoord, hex: hex!)
                        marker.record = geoRecord
                        marker.coinData = ["uid" : uid]
                        self.recordsOnMap[geoRecord.name()] = marker
                        marker.map = self.mapView
                        let coinRadarView = UIImageView.init(image: UIImage(named: "bitcoin-icon")?.resized(withPercentage: CGFloat(kCoinPercent)))
                        coinRadarView.isHidden = true
                        self.mapView.addSubview(coinRadarView)
                        self.recordsOnRadar[geoRecord.name()] = coinRadarView
                        
                        
                    }
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
                self.removeOldMarker(name : recordName)
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
            default:
                print("default do nothing:" + recordName)
        }
    }
}

