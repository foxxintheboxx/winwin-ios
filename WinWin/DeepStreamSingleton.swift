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
    var userRecord: Record?
    
    static let sharedInstance : DeepStreamSingleton = {
        let instance = DeepStreamSingleton()
        instance.setup()
        return instance
    }()
    
    override
    init() {
        let global = "winwin-ds-server.herokuapp.com:80"
        let local = "127.0.0.1:6020"
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
            self.userUID = data?["uid"] as! String?
            self.userRecord = self.client?.record.getRecord("users/" + self.userUID!)
            print("Subscriber: Login Success")
            return true
        }
        
    }
    
    func subscribeRecord(recordName: String, callback : RecordChangedCallback) {
        
    }
    
    
}
