//
//  MarkerViewController.swift
//  WinWin
//
//  Created by Ian Fox on 3/12/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import UIKit

class MarkerViewController : UIViewController {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }

}
