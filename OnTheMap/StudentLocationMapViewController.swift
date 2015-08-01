//
//  SecondViewController.swift
//  OnTheMap
//
//  Created by Steven on 28/06/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var locationAnnotations: [MKPointAnnotation] = [MKPointAnnotation]()
    var appDelegate: AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
    }

    override func viewWillAppear(animated: Bool) {
    	super.viewWillAppear(animated)
        
        // In case of studentLocations from AppDelegate is empty, this means we haven't
        // load the studentLocations from Parse API yet, so we call loadStudentLocations -
        // this will load the studentLocations, and generateMapAnnotations to populate the pins.
        if appDelegate.studentLocations.count == 0 {
            loadStudentLocations(completionHandler: { () -> Void in
                self.generateMapAnnotations()
            })
        } else {
            self.generateMapAnnotations()
        }
        
    	configureUI()
    }

    // MARK: UI methods

    /**
    Configure this screen's UI
    Populate logout, refresh and post location button on navigation item
    */
    func configureUI() {
    	// Set navigation buttons
    	var logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "processLogout")
    	var refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshStudentLocations")
    	var postLocationButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "displayPostStudentLocationModal")
    	
    	self.parentViewController!.navigationItem.leftBarButtonItem = logoutButton
    	self.parentViewController!.navigationItem.rightBarButtonItems = [refreshButton, postLocationButton]
    }

    /**
    Opens up alert view and display the given message
    
    :param: message
    :param: actionString        The action name
    :param: actionHandler       What action should be done if user tapped the action button?
    */
    func displayAlert( message: String, actionString: String, actionHandler: () -> () ) {
        var alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction( UIAlertAction(title: actionString, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            actionHandler()
        }))
        alert.addAction( UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: Button Actions

    /**
    Logout Button Action
    Logout from Udacity and return to root view controller
    */
    func processLogout() {
        self.dismissViewControllerAnimated(true) {
            UdacityClient.sharedInstance().logout() {
                success, errorString in 

                if let error = errorString {
                    println("Logout failed")
                } 
            }
        } 
    }

    /**
    Refresh Button Action
    Refresh the studentLocations array by making another request to Parse API 
    */
    func refreshStudentLocations() {
    	loadStudentLocations() {
			dispatch_async( dispatch_get_main_queue() ) {
				self.generateMapAnnotations()
			}
    	}
    }

    /**
    Post Student Location Button Action
    Display post student location modal
    */
    func displayPostStudentLocationModal() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PostStudentLocationViewController") as! PostStudentLocationViewController

        self.presentViewController(controller, animated: true, completion: nil)
    }

    // MARK: MKMapView Delegate methods

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
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    /**
    Pin Tapped Action
    We want to open the MediaURL in browser
    */
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }

    // MARK: Helper methods

    /**
    Load the first 100 records of StudentLocation from Parse API
    
    :param: completionHandler
    */
    func loadStudentLocations( completionHandler: (() -> Void)? = nil ) {
        // Get the first 100 student locations and store them in appDelegate
        ParseClient.sharedInstance().getStudentLocations( 100 ) {
            results, error in 
            
            if let error = error {
                self.displayAlert( "Could not retrieve Student Information. Would you like to retry?", actionString: "Retry" ) {
                    self.loadStudentLocations( completionHandler: nil )
                }
            } else {

                self.appDelegate.studentLocations = results!
                
                if let handler: () -> Void = completionHandler {
                    handler()
                }
            }
        }
    }

    /**
    Generate annotations in Map with the loaded student locations
    */
    func generateMapAnnotations() {

        dispatch_async( dispatch_get_main_queue() ) {
            
            // Remove all annotations
            self.mapView.removeAnnotations(self.locationAnnotations)
            
            for studentLocation in self.appDelegate.studentLocations {
                
                // Determine coordinate
                let lat = CLLocationDegrees(studentLocation.latitude!)
                let long = CLLocationDegrees(studentLocation.longitude!)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                // Get the firstname, lastname and media URL for display in annotation
                let first = studentLocation.firstName!
                let last = studentLocation.lastName!
                let mediaURL = studentLocation.mediaURL!
                
                // Construct the annotation
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                self.locationAnnotations.append(annotation)
                
            }
            
            // Add annotations to map
            self.mapView.addAnnotations(self.locationAnnotations)
            
        }


    }

}

