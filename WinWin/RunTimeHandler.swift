//
//  RunTimeHandler.swift
//  WinWin
//
//  Created by Ian Fox on 3/11/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//


import Foundation

final class RuntimeErrorHandler : NSObject, DeepstreamRuntimeErrorHandler {
    func onException(_ topic: Topic!, event: Event!, errorMessage: String!) {
        if (errorMessage != nil && topic != nil && event != nil) {
            print("Error: \(errorMessage!) for topic: \(topic!), event: \(event!)")
        }
    }
}
