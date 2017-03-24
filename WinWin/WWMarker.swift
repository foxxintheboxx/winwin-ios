//
//  WWMarker.swift
//  WinWin
//
//  Created by Ian Fox on 3/21/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import Foundation
class WWMarker : GMSMarker {
    var coinData : [String : String]?
    var record : Record?
    init(coordinate: CLLocationCoordinate2D) {
        super.init()
        position = coordinate
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = kGMSMarkerAnimationPop
    }
}
