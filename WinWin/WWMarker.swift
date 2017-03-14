//
//  WWMarker.swift
//  WinWin
//
//  Created by Ian Fox on 3/12/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import UIKit

class WWMarker: GMSMarker {
    var coinData : [String : Any]?
    
    init(coordinate: CLLocationCoordinate2D) {
        super.init()
        
        position = coordinate
        icon = UIImage(named: "bitcoin-icon")?.resizeWith(percentage: 0.10)
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
    }
}
