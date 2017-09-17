//
//  SignupResultsViewController.swift
//  WinWin
//
//  Created by Ian Fox on 4/4/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//
//


import UIKit

class SignupResultsViewController: UIViewController {
    
    @IBOutlet var proceedButton: UIButton!
    @IBOutlet var resultTitleLabel: UILabel!
    @IBOutlet var resultInfoTextView: UITextView!
    var isError: Bool = false
    var userMessage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultInfoTextView.text = userMessage;
        if (isError) {
            let coralColor = UIColor.init(hexString: kCoralRed);
            proceedButton.backgroundColor = coralColor
            resultTitleLabel.textColor = coralColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onProceed(_ sender: Any) {
        
    }
    
}
