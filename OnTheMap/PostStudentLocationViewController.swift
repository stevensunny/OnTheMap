//
//  PostStudentLocationViewController.swift
//  OnTheMap
//
//  Created by Steven on 12/07/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import UIKit
import MapKit

class PostStudentLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnFindOnTheMap: UIButton!

    var tapRecognizer: UITapGestureRecognizer? = nil
    
    var myLocation: StudentLocation! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myLocation = StudentLocation(uniqueKey: UdacityClient.sharedInstance().userID!, firstName: UdacityClient.sharedInstance().firstName!, lastName: UdacityClient.sharedInstance().lastName!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.configureUI()
        
        self.addKeyboardDismissRecognizer()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.removeKeyboardDismissRecognizer()
    }

    // MARK: UI Methods

    /**
    Configure this screen's UI
    */
    func configureUI() {

        // Title Label
        let titleAttributedString = NSMutableAttributedString(string: "Where are you\nstudying\ntoday?")
        
        // Line height and text alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 30
        paragraphStyle.alignment = NSTextAlignment.Center
        titleAttributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, titleAttributedString.length))
        
        // Font
        titleAttributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Roboto-Thin", size: 20)!, range: NSMakeRange(0, 13))
        titleAttributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Roboto-Medium", size: 20)!, range: NSMakeRange(14, 8))
        titleAttributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Roboto-Thin", size: 20)!, range: NSMakeRange(23, 6))
        
        self.labelTitle.textColor = UIColor(red: 0.298, green: 0.522, blue: 0.698, alpha: 1.0)
        self.labelTitle.attributedText = titleAttributedString

        // Single tap gesture recognizer - to dismiss keyboard when user tapped the screen
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }

    /**
    Opens up alert view and display the given message
    
    :param: message
    :param: actionString        The action name
    :param: actionHandler       What action should be done if user tapped the action button?
    */
    func displayAlert( title: String, message: String, actionPrompt: String, actionHandler: (() -> Void)? = nil ) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction( UIAlertAction(title: actionPrompt, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if let actionHandler = actionHandler {
                actionHandler()
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Button Actions
    
    /**
    Cancel Button Action
    Dismiss this screen
    */
    @IBAction func processCancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    Find On The Map Button Action
    Geocode string input and display on map
    */
    @IBAction func findOnTheMap(sender: UIButton) {

        let address = txtAddress.text
        if address == "" {
            self.displayAlert("Invalid Address", message: "Oops, you haven't filled in your address yet.", actionPrompt: "OK", actionHandler: { () -> Void in 
                    self.txtAddress.becomeFirstResponder()
                })
        } else {
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            var geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if let placemark = placemarks?[0] as? CLPlacemark {
                    let postStudentUrlViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PostStudentURLViewController") as! PostStudentURLViewController
                    
                    postStudentUrlViewController.placemark = MKPlacemark(placemark: placemark)
                    
                    // Assign the mapString, latitude and longitude to class' StudentLocation
                    self.myLocation.mapString = "\(placemark.locality), \(placemark.administrativeArea)"
                    self.myLocation.latitude = placemark.location.coordinate.latitude
                    self.myLocation.longitude = placemark.location.coordinate.longitude
                    postStudentUrlViewController.myLocation = self.myLocation!
                    
                    self.presentViewController(postStudentUrlViewController, animated: true, completion: nil)
                    
                } else {
                    self.displayAlert("Invalid Address", message: "Could not find a place with the name: \(address). Perhaps try different address?", actionPrompt: "OK", actionHandler: { () -> Void in 
                        self.txtAddress.becomeFirstResponder()
                    })
                }
            })
        }

    }

    // MARK: Keyboard Behavior
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: TextField Delegate
    
    /**
    Clear the textfield everytime it's tapped
    */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        txtAddress.text = ""
        return true
    }
    
    /**
    Simulate call to findOnTheMap when enter is tapped
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.findOnTheMap(btnFindOnTheMap)
        return true
    }
    
}