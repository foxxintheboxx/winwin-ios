//
//  UserProfileViewController.swift
//  WinWin
//
//  Created by Ian Fox on 3/11/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    @IBOutlet var viewDonationHistoryButton: UIButton!
    @IBOutlet var getItemsButton: UIButton!
    @IBOutlet var giveButton: UIButton!
    @IBOutlet var donatedCountLabel: UILabel!
    @IBOutlet var pickupCountLabel: UILabel!
    @IBOutlet var coinCountLabel: UILabel!
    @IBOutlet var statsView: UIView!
    @IBOutlet var headerView: UIView!
    var dsSingleton: DeepStreamSingleton?
    var userAccount: Record?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.isHidden = true
        viewDonationHistoryButton.roundedButton()
        getItemsButton.roundedButton()
        giveButton.roundedButton()
        DispatchQueue.global().async {
            self.dsSingleton = DeepStreamSingleton.sharedInstance;
            self.userAccount = self.dsSingleton?.client?.record.getRecord("users/" + (self.dsSingleton?.userUID)!)
            self.userAccount?.whenReady(self)
            self.userAccount?.subscribe(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension UserProfileViewController {
    
    func populateUserStats(user: Record) {
        let data = user.get().deepDict
        let accountValue = data["account"] as! Int?
        if let val = accountValue {
            self.coinCountLabel.text = "\(val)"
        }
    }
    
    func updateUserStats(user: JsonElement) {
        let data = user.deepDict
        let accountValue = data["account"] as! Int?
        if let val = accountValue {
            DispatchQueue.main.async {
                self.coinCountLabel.text? = "\(val)"
            }
        }
    }
    
}

// MARK: DSClient Background Calls
extension UserProfileViewController: RecordReadyListener, RecordChangedCallback, RecordPathChangedCallback {
    
    /*!
     @brief Called when the listener is added via <code>Record.subscribe(String,RecordPathChangedCallback,boolean)</code><br/>
     Will contain the data under the path, regardless of whether triggered by a Patch or Update
     @param recordName The name of the record change
     @param path The path subscribed to
     @param data The data under the path as an Object
     */
    public func onRecordPathChanged(_ recordName: String!, path: String!, data: JsonElement!) {
    }
    
    /*!
     @brief Called when the record is loaded from the server
     @param recordName The name of the record which is now ready
     @param record     The record which is now ready / loaded from server
     */
    public func onRecordReady(_ recordName: String!, record: Record!) {
        let recordNameArray = recordName.components(separatedBy: "/")
        
        switch recordNameArray[0] {
        case "users":
            self.populateUserStats(user: record)
        default:
            print("default do nothing:" + recordName)
        }
        
    }
    
    func onRecordChanged(_ recordName: String!, data: JsonElement!) {
        let recordNameArray = recordName.components(separatedBy: "/")
        switch recordNameArray[0] {
        case "users":
            self.updateUserStats(user: data)
        default:
            print("default do nothing:" + recordName)
        }
    }
}

