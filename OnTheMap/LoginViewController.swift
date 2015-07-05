//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Steven on 28/06/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    

    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var signUpWithFacebookButton: BorderedButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var backgroundGradient: CAGradientLayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
    }
    
    // MARK: UI
    
    /**
    Configure Login Screen UI Element
    */
    func configureUI() {
        
        self.setDefaultBackgroundStyle()
        
        self.setDefaultLabelStyle(titleLabel, fontSize: 24.0)
        self.setDefaultLabelStyle(debugLabel)
        
        self.setDefaultTextfieldStyle(emailTextfield)
        self.setDefaultTextfieldStyle(passwordTextfield)
        
        self.setDefaultBorderedButtonStyle(loginButton, mainColor: UIColor(red: 1.0, green: 0.333, blue: 0.0, alpha: 1.0), highlightColor: UIColor(red: 0.902, green: 0.235, blue: 0.0, alpha:1.0))
        self.setDefaultBorderedButtonStyle(signUpWithFacebookButton, mainColor: UIColor(red: 0.286, green: 0.416, blue: 0.800, alpha: 1.0), highlightColor: UIColor(red: 0.188, green: 0.318, blue: 0.612, alpha: 1.0))
        
        
        // Configure sign up button
        signUpButton.titleLabel?.font = UIFont(name:"AvenirNext-Medium", size: 17.0)
        
    }
    
    // MARK: UI Helper Function
    
    func setDefaultBackgroundStyle() {
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 1.0, green: 150/255.0, blue: 10/255.0, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 1.0, green: 110/255.0, blue: 0.0, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient, atIndex: 0)
    }
    
    func setDefaultLabelStyle( label: UILabel, fontSize: CGFloat = 17.0 ) {
        label.font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        label.textColor = UIColor.whiteColor()
    }
    
    func setDefaultTextfieldStyle( textField: UITextField ) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        textField.backgroundColor = UIColor(red: 1.0, green: CGFloat( 198/255.0 ), blue: CGFloat( 147/255.0 ), alpha:1.0)
        textField.textColor = UIColor.whiteColor()
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)])
        textField.tintColor = UIColor(red: 1.0, green: 100/255.0, blue:2/255.0, alpha: 1.0)
    }
    
    func setDefaultBorderedButtonStyle( button: BorderedButton, mainColor: UIColor, highlightColor: UIColor ) {
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        button.highlightedBackingColor = highlightColor
        button.backingColor = mainColor
        button.backgroundColor = mainColor
    }
    
    func clearDebugLabel() {
        self.displayError("")
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugLabel.text = errorString
            }
        })
    }
    
    // MARK: IB Actions
    @IBAction func processLogin(sender: BorderedButton) {
        
        clearDebugLabel()
        
        let email = self.emailTextfield.text
        let password = self.passwordTextfield.text

        // Show error message if email / password field is empty
        if ( email == "" || password == "" ) {
            self.displayError("Please enter your email and password")
            return
        }
        
        UdacityClient.sharedInstance().authenticateWithEmail(email, password: password) { (success, errorString) -> Void in
            
            if !success {
                
                self.displayError(errorString)
                
            } else {
                
                self.displayError("Success")
                
            }
            
        }
        
        
    }

}


