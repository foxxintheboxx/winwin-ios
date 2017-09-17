//
//  StoreViewController.swift
//  WinWin
//
//  Created by Ian Fox on 4/5/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import UIKit

class StoreViewController: ModalViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
    }
}
