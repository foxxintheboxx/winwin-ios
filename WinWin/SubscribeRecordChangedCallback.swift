//
//  SubscribeRecordChangeSingleton.swift
//  WinWin
//
//  Created by Ian Fox on 3/11/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import Foundation

final class SubscribeRecordChangedCallback : NSObject, RecordChangedCallback {
    
    static let sharedInstance : SubscribeRecordChangedCallback = {
        let instance = SubscribeRecordChangedCallback()
        return instance
    }()
    
    var callbacksDict = [String : [WWRecordChangedCallback]!]()
    
    func onRecordChanged(_ recordName: String!, data: JsonElement!) {
        if let callbacks : [WWRecordChangedCallback]? = self.callbacksDict[recordName] {
            for callback in callbacks! {
                callback.onRecordChanged(recordName, data: data)
            }
        }
        print("Subscriber: Record '\(recordName!)' changed, data is now: \(data.dict)")
    }
    
    func removeSubscription(_ recordName: String!, callbackName: String!) {
        if var callbacks : [WWRecordChangedCallback]? = self.callbacksDict[recordName] {
            var indexToDelete : Int?
            for (index, callback) in callbacks!.enumerated() {
                if String(describing: callback) == callbackName {
                    indexToDelete = index
                    break
                }
            }
            if let index = indexToDelete {
                callbacks!.remove(at: index)
            }
        }
    }
    func addSubscription(_ recordName: String!, callback: WWRecordChangedCallback) {
        if var callbacks = self.callbacksDict[recordName] {
            callbacks.append(callback)
        } else {
            self.callbacksDict[recordName] = [callback];
        }
        
    }
}
