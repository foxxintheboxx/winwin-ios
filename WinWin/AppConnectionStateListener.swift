//
//  AppConnectionStateListener.swift
//  WinWin
//
//  Created by Ian Fox on 3/11/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import Foundation

final class AppConnectionStateListener : NSObject, ConnectionStateListener {
    func connectionStateChanged(_ connectionState: ConnectionState!) {
        print("Connection state changed \(connectionState!)")
    }
}
