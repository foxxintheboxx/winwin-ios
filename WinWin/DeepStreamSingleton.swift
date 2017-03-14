//
//  DeepStreamSingleton.swift
//  WinWin
//
//  Created by Ian Fox on 3/11/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

class DeepStreamSingleton : NSObject {
    


    //MARK: Shared Instance
    var client : DeepstreamClient?
    var username: String? // LATER change to oauth token
    var password: String?
    //var userData: [String : String]? // change to purely Stack memory
    var userUID : String?
    
    static let sharedInstance : DeepStreamSingleton = {
        let instance = DeepStreamSingleton()
        instance.setup()
        return instance
    }()
    
    override
    init() {
        client = DeepstreamClient("127.0.0.1:6020")
    }
    
    //MARK: Local Variable
    

    
    //MARK: Init Array

    
    func setup() {
        
    }
    
    func login() -> Bool {
        let authData = ["username" : username, "password": password]
        guard let loginResult = client?.login(authData.jsonElement) else {
            print("Unable to get login result")
            return false
        }
        if (!loginResult.loggedIn()) {
            print("Subscriber: Failed to login \(loginResult.getErrorEvent())")
            return false
        } else {
            let jsonData = loginResult.getData() as? JsonObject
            let data = jsonData?.dict as? [String: Any?]
            print(jsonData)
            print(data)
            self.userUID = data?["uid"] as! String?
            print("Subscriber: Login Success")


            return true
        }
        
    }
    
    func subscribeRecord(recordName: String, callback : RecordChangedCallback) {
        
    }
    
    
}
