//
//  WWCrumbMarker.swift
//  WinWin
//
//  Created by Ian Fox on 3/21/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import Foundation

class WWCrumbMarker : WWMarker {
    
    init(coordinate: CLLocationCoordinate2D, hex: String) {
        super.init(coordinate: coordinate)
        icon = UIImage.circle(diameter: 20, color: UIColor.init(hexString: hex))
    }
}
