//
//  BearingiewBound.swift
//  WinWin
//
//  Created by Ian Fox on 4/6/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import Foundation

class BearingViewBound: NSObject {
    var q4q1center: Float = 0
    var q1: Float = 45.0
    var q1q2center: Float = 90
    var q2: Float = 135.0
    var q2q3center: Float = 180.0
    var q3: Float = 225.0
    var q3q4center: Float = 270.0
    var q4: Float = 315.0

    init(center: Float) {
        super.init()
        q4q1center = center
    }
    
    func calculateCenters() {
        q1q2center = (q1 < q2) ? (q1 + q2) / 2.0 : 360.0
        q2q3center = (q2 < q3) ? (q2 + q3) / 2.0 : 360.0
        q3q4center = (q3 < q4) ? (q3 + q4) / 2.0 : 360.0

    }
}
