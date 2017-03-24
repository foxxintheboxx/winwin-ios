//
//  GeoPointCompass.swift
//  WinWin
//
//  Created by Ian Fox on 3/16/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//


class GeoPointCompass : NSObject, CLLocationManagerDelegate {

    var arrowImageView: UIView?

    private var angle:    Float = 0
    
    override init() {
        super.init()
    }
    
    // MARK: Private methods
    
    private func degreesToRadians(degrees: Float) -> Float {
        return degrees * Float(M_PI) / 180
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        var direction: Float = Float(newHeading.magneticHeading)
        
        self.updateArrowDirection(direction: direction)
        
        //    let currentLocation: CLLocation = manager.location!
    }
    
    func updateArrowDirection(direction : Float) {
        
        var direction : Float = 0
        if direction > 180 {
            direction = 360 - direction
        }
        else {
            direction = 0 - direction
        }
        
        // Rotate the arrow image
        if let arrowImageView = self.arrowImageView {
            UIView.animate(withDuration: 3.0, animations: { () -> Void in
                let rotationAngle = CGFloat(self.degreesToRadians(degrees: direction) + self.angle)
                arrowImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
                
            })
        }
        
        //    let currentLocation: CLLocation = manager.location!
    }
    
    
    
    
    
}
