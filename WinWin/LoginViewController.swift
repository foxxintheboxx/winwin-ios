//
//  LoginViewController.swift

//  WinWin
//
//  Created by Ian Fox on 3/11/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var signupButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loginButton.isUserInteractionEnabled = false;
        self.usernameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        //self.usernameTextField.returnKeyType = UIReturnKeyType.continue
        self.usernameTextField.returnKeyType = UIReturnKeyType.done
        self.passwordTextField.returnKeyType = UIReturnKeyType.done
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        self.loginButton.roundedButton()
        self.signupButton.roundedButton()
        self.titleLabel.textColor = UIColor.init(hexString: kCoralRed)
        self.loginButton.backgroundColor = UIColor.init(hexString: kRiverBlue)
        self.signupButton.backgroundColor = UIColor.init(hexString: kCoralRed)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.usernameTextField) {
            print("here")
  //          self.passwordTextField.becomeFirstResponder()
            self.usernameTextField.resignFirstResponder()

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
       // if ((self.usernameTextField.text?.characters.count)! > 0 && (self.passwordTextField.text?.characters.count)! > 0) {
            self.loginButton.isUserInteractionEnabled = true
       // }
    }
    
    
    @IBAction func doLogin(_ sender: UIButton) {
        DispatchQueue.global().async {

            let dsClient = DeepStreamSingleton.sharedInstance
            dsClient.username = self.usernameTextField.text
           // dsClient.password = self.passwordTextField.text
            dsClient.password = "1234"
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
        let userProfileViewController = self.storyboard?.instantiateViewController(withIdentifier :"UserProfileViewController") as! UserProfileViewController
        let activityFeedViewController = self.storyboard?.instantiateViewController(withIdentifier :"ActivityFeedViewController") as! ActivityFeedViewController
        let snapContainerVC = self.storyboard?.instantiateViewController(withIdentifier: "GameContainerViewController") as! SnapContainerViewController
        let navigationProfileViewController = UINavigationController.init(rootViewController: snapContainerVC)
        navigationProfileViewController.navigationBar.isHidden = true;
        snapContainerVC.middleVc = mapViewController
        snapContainerVC.leftVc = userProfileViewController
        snapContainerVC.rightVc = activityFeedViewController
        snapContainerVC.radarDelegate = mapViewController
        //snapContainerVC.leftVc = navigationProfileViewController
        self.present(navigationProfileViewController, animated: true)
    }
}

