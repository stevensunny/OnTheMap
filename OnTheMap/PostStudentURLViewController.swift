//
//  PostStudentURLViewController.swift
//  OnTheMap
//
//  Created by Steven on 19/07/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PostStudentURLViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnPreview: UIButton!
    @IBOutlet weak var txtUrl: UITextField!
    
    var placemark: MKPlacemark? = nil
    let regionRadius: CLLocationDistance = 100000
    
    var myLocation: StudentLocation! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addPlacemarkAnnotation()
        self.centerMapOnLocation(placemark!.location!)
        
    }
    
    override func viewWillAppear( animated: Bool ) {
        super.viewWillAppear( animated )
        
        btnPreview.alpha = 0.0
        
        self.mapView.selectAnnotation(placemark, animated: true)
    }
    
    // MARK: Helper Methods
    
    /**
    Add annotation for the placemark entered
    */
    func addPlacemarkAnnotation() {
        self.mapView.removeAnnotation(placemark)
        self.mapView.addAnnotation(placemark)
    }
    
    /**
    Center the map to the given location
    
    :param: location
    */
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    /**
    Build correct URL by appending URL schema (http://) if the string doesn't have one
    
    :param: urlString
    
    :returns: NSURL
    */
    func buildCorrectUrl( urlString: String ) -> NSURL {

        if urlString.lowercaseString.rangeOfString("http") != nil {
            return NSURL(string: urlString)!
        } else {
            return NSURL(string: "http://\(urlString)")!
        }
        
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
    
    // MARK: MapViewDelegate Methods
    
    /**
    Annotations / Pin configurations
    */
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    // MARK: Button Actions
    
    @IBAction func processPreviewUrl(sender: UIButton) {
        
        let urlString = self.txtUrl.text
        
        UIApplication.sharedApplication().openURL( self.buildCorrectUrl(urlString) )

    }
    
    /**
    Cancel Button Action
    Dismiss this screen
    */
    @IBAction func processCancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    Submit the location to Parse API
    
    :param: sender UIButton
    */
    @IBAction func processSubmitLocation(sender: UIButton) {
        let urlString = txtUrl.text
        
        if urlString == "" {
            self.displayAlert("Invalid URL", message: "Oops, you haven't entered your URL yet", actionPrompt: "OK", actionHandler: { () -> Void in
                txtUrl.becomeFirstResponder()
            })
        } else {
            
            let url: NSURL = self.buildCorrectUrl(urlString)
            myLocation.mediaURL = url.absoluteString
            
            ParseClient.sharedInstance().postStudentLocation(myLocation, completionHandler: { (success, error) -> Void in
                if let error = error {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.displayAlert("Post Location Failed", message: "Oops, we can't post your location at this time. Please try again in a few minutes", actionPrompt: "OK", actionHandler: nil)
                    })
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // We empty the studentLocations in the appDelegate to force the MapView to reload the studentLocations
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.studentLocations = []
                        
                        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        
                    })
                    
                }
            })
        }
    }
    
    // MARK: TextField Delegate Methods
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        txtUrl.text = ""
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let old_url = textField.text as NSString
        var new_url = old_url.stringByReplacingCharactersInRange(range, withString: string) as String
        if new_url != "" && count(new_url) > 3 {
            btnPreview.alpha = 1.0
        } else {
            btnPreview.alpha = 0.0
        }
        return true
    }
}
