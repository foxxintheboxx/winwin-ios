//
//  ContainerViewController.swift
//  SnapchatSwipeView
//
//  Created by Jake Spracher on 8/9/15.
//  Copyright (c) 2015 Jake Spracher. All rights reserved.
//

import UIKit
import Pulsator


protocol SnapContainerViewControllerDelegate {
    func outerScrollViewShouldScroll() -> Bool
}

protocol RadarViewControllerDelegate {
    func toggleRadar(_ usingRadar: Bool) -> Void
}

class SnapContainerViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var statsView: UIStackView!
    @IBOutlet var coinsCountLabel: UILabel!
    @IBOutlet var pickupsCountLabel: UILabel!
    
    @IBOutlet var radarButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    var topVc: UIViewController?
    var leftVc: UIViewController!
    var middleVc: UIViewController!
    var rightVc: UIViewController!
    var bottomVc: UIViewController?
    
    var directionLockDisabled: Bool!
    var usingRadar: Bool = false
    var pulsator: Pulsator = Pulsator()

    
    var horizontalViews = [UIViewController]()
    var veritcalViews = [UIViewController]()
    
    var initialContentOffset = CGPoint() // scrollView initial offset
    var middleVertScrollVc: VerticalScrollViewController!
    var delegate: SnapContainerViewControllerDelegate?
    var radarDelegate: RadarViewControllerDelegate?
    var userAccount: Record?
    
    var dsSingleton: DeepStreamSingleton?
    
    class func containerViewWith(_ leftVC: UIViewController?=nil,
                                 middleVC: UIViewController,
                                 rightVC: UIViewController?=nil,
                                 topVC: UIViewController?=nil,
                                 bottomVC: UIViewController?=nil,
                                 directionLockDisabled: Bool?=false) -> SnapContainerViewController {
        let container = SnapContainerViewController()
        
        container.directionLockDisabled = directionLockDisabled
        
        container.topVc = topVC
        container.leftVc = leftVC
        container.middleVc = middleVC
        container.rightVc = rightVC
        container.bottomVc = bottomVC
        return container
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVerticalScrollView()
        setupHorizontalScrollView()
        pulsator.backgroundColor = UIColor.init(hexString: kRadarGreen).cgColor
        pulsator.position = (radarButton.imageView?.center)!
        pulsator.radius = 50.0
        pulsator.numPulse = 5
        radarButton.imageView?.layer.addSublayer(pulsator)
        DispatchQueue.global().async {
            self.dsSingleton = DeepStreamSingleton.sharedInstance;
            self.userAccount = self.dsSingleton?.client?.record.getRecord("users/" + (self.dsSingleton?.userUID)!)
            self.userAccount?.whenReady(self)
            self.userAccount?.subscribe(self)
        }
        
    }
    
    func setupVerticalScrollView() {
        middleVertScrollVc = VerticalScrollViewController.verticalScrollVcWith(middleVc: middleVc,
                                                                               topVc: topVc,
                                                                               bottomVc: bottomVc)
        delegate = middleVertScrollVc
    }
    
    func setupHorizontalScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        let view = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        
        scrollView.frame = CGRect(x: view.x,
                                  y: view.y,
                                  width: view.width,
                                  height: view.height
        )
        
        //self.view.addSubview(scrollView)
        
        let scrollWidth  = 3 * view.width
        let scrollHeight  = view.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        if (leftVc != nil) {
            leftVc.view.frame = CGRect(x: 0,
                                       y: 0,
                                       width: view.width,
                                       height: view.height
            )
            addChildViewController(leftVc)
            scrollView.addSubview(leftVc.view)
            leftVc.didMove(toParentViewController: self)

        }
        
        middleVertScrollVc.view.frame = CGRect(x: view.width,
                                               y: 0,
                                               width: view.width,
                                               height: view.height
        )
        addChildViewController(middleVertScrollVc)
        scrollView.addSubview(middleVertScrollVc.view)
        middleVertScrollVc.didMove(toParentViewController: self)


        if (rightVc != nil) {
            rightVc.view.frame = CGRect(x: 2 * view.width,
                                        y: 0,
                                        width: view.width,
                                        height: view.height
            )
            addChildViewController(rightVc)
            scrollView.addSubview(rightVc.view)
            rightVc.didMove(toParentViewController: self)
        }
        
        scrollView.contentOffset.x = middleVertScrollVc.view.frame.origin.x
        scrollView.delegate = self
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.initialContentOffset = scrollView.contentOffset
        toggleStatsView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        toggleStatsView()
        if delegate != nil && !delegate!.outerScrollViewShouldScroll() && !directionLockDisabled {
            let newOffset = CGPoint(x: self.initialContentOffset.x, y: self.initialContentOffset.y)
            
            // Setting the new offset to the scrollView makes it behave like a proper
            // directional lock, that allows you to scroll in only one direction at any given time
            self.scrollView!.setContentOffset(newOffset, animated:  false)
        }
    }
    
    func toggleStatsView() {
        if (self.scrollView.contentOffset.x != middleVertScrollVc.view.frame.origin.x) {
            statsView.isHidden = true
        } else {
            statsView.isHidden = false
        }
    }
    
    @IBAction func viewUserProfile(_ sender: Any) {
        statsView.isHidden = true
        scrollView.contentOffset.x = leftVc.view.frame.origin.x
        onRadarChange(usingRadar: false)
    }
    
    @IBAction func touchRadar(_ sender: Any) {
        statsView.isHidden = false
        if scrollView.contentOffset.x == middleVertScrollVc.view.frame.origin.x {
            usingRadar = !usingRadar
            onRadarChange(usingRadar: usingRadar)
        } else {
            scrollView.contentOffset.x = middleVertScrollVc.view.frame.origin.x
        }
    }
    
    @IBAction func viewFriendActivity(_ sender: Any) {
        statsView.isHidden = true
        scrollView.contentOffset.x = rightVc.view.frame.origin.x
        onRadarChange(usingRadar: false)
    }
    
    func onRadarChange(usingRadar: Bool) {
        radarDelegate?.toggleRadar(usingRadar)
        if usingRadar {
            pulsator.start()
        } else {
            pulsator.stop()
        }
    }
}

// MARK: DSClient Helpers
extension SnapContainerViewController {
    
    func populateUserStats(user: Record) {
        let data = user.get().deepDict
        let accountValue = data["account"] as! Int?
        if let val = accountValue {
            self.coinsCountLabel.text = "\(val)"
        }
    }
    
    func updateUserStats(user: JsonElement) {
        let data = user.deepDict
        let accountValue = data["account"] as! Int?
        if let val = accountValue {
            DispatchQueue.main.async {
                self.coinsCountLabel.text? = "\(val)"
            }
        }
    }
    
}

// MARK: DSClient Background Calls
extension SnapContainerViewController: RecordReadyListener, RecordChangedCallback, RecordPathChangedCallback {
    
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
