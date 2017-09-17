//
//  SignupViewController.swift

//  WinWin
//
//  Created by Ian Fox on 3/11/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import UIKit


class SignupViewController: ModalViewController {
    
    @IBOutlet var titleLabelContainerView: UIView!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var phoneNumberField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var confirmPasswordField: UITextField!
    @IBOutlet var doneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.roundedButton()
        doneButton.backgroundColor = UIColor.init(hexString: kRiverBlue)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccountAndLogin(_ sender: UIButton) {
        //Check if username exists
        
        
    }
    
}

