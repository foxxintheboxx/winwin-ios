//
//  WWCoinMarker.swift
//  WinWin
//
//  Created by Ian Fox on 3/12/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import UIKit

class WWCoinMarker : WWMarker {
    
    override init(coordinate: CLLocationCoordinate2D) {
        super.init(coordinate: coordinate)
        iconView = UIImageView.init(image: UIImage(named: "bitcoin-icon")?.resized(withPercentage: CGFloat(kCoinPercent)))
    }
}
