//
//  LoginViewController.swift

//  WinWin
//
//  Created by Ian Fox on 3/11/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loginButton.isUserInteractionEnabled = false;
        self.usernameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.usernameTextField.returnKeyType = UIReturnKeyType.continue
        self.passwordTextField.returnKeyType = UIReturnKeyType.done
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.usernameTextField) {
            print("here")
            self.passwordTextField.becomeFirstResponder()
        } else {
            self.passwordTextField.resignFirstResponder()
        }
        return false
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
        let mapViewController = self.storyboard?.instantiateViewController(withIdentifier :"GameMapViewController") as! GameMapViewController
        let gameMenuViewController = self.storyboard?.instantiateViewController(withIdentifier :"GameMenuViewController") as! GameMenuViewController
        let vertScrollViewController = VerticalScrollViewController.verticalScrollVcWith(middleVc: mapViewController,
                                                                                         topVc: nil,
                                                                                         bottomVc: gameMenuViewController)
        
        self.present(vertScrollViewController, animated: true)
    }
}

