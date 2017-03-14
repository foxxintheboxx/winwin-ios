//
//  LoginViewController.swift

//  WinWin
//
//  Created by Ian Fox on 3/11/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loginButton.isUserInteractionEnabled = false;
        self.usernameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if ((self.usernameTextField.text?.characters.count)! > 0 && (self.passwordTextField.text?.characters.count)! > 0) {
            self.loginButton.isUserInteractionEnabled = true
        }
    }
    
    
    @IBAction func doLogin(_ sender: UIButton) {
        DispatchQueue.global().async {

            let dsClient = DeepStreamSingleton.sharedInstance
            dsClient.username = self.usernameTextField.text
            dsClient.password = self.passwordTextField.text
            print("hello")
            if dsClient.login() {
                DispatchQueue.main.async {
                    self.segueToVertScrollController();
                }
            }
            
        }
    }
    
    func segueToVertScrollController() {
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier :"MapViewController") as! MapViewController
        let gameMenuViewController = self.storyboard?.instantiateViewController(withIdentifier :"GameMenuViewController") as! GameMenuViewController
        let vertScrollViewController = VerticalScrollViewController.verticalScrollVcWith(middleVc: mapViewController,
                                                                                         topVc: nil,
                                                                                         bottomVc: gameMenuViewController)
        
        self.present(vertScrollViewController, animated: true)
    }
}

