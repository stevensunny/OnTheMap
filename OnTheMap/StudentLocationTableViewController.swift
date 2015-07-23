//
//  FirstViewController.swift
//  OnTheMap
//
//  Created by Steven on 28/06/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import UIKit

class StudentLocationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var studentLocationTableView: UITableView!

    var studentLocations: [StudentLocation]!
    var appDelegate: AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // Get student locations from AppDelegate
        self.studentLocations = self.appDelegate.studentLocations

        // In case of studentLocations from AppDelegate is empty, this means we haven't 
        // load the studentLocations from Parse API yet, so we call loadStudentLocations -
        // this will load the studentLocations, and reloadTableViewData to reload the table
        if self.studentLocations.count == 0 {
            loadStudentLocations(completionHandler: { () -> Void in
                self.reloadTableViewData()
            })
        } else {
            self.reloadTableViewData()
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
    }
    
    // MARK: UI Methods

    /**
    Configure UI for this screen
    */
    func configureUI() {
        // Remove table view extra separator
        self.studentLocationTableView.tableFooterView = UIView()

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
        loadStudentLocations { () -> Void in
            self.reloadTableViewData()
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
    
    // MARK: Table View Delegate and Data Source
    
    /**
    Configure table view cell
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Get cell type
        let cellReuseIdentifier = "StudentLocationViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        // Set cell default
        let item = studentLocations[indexPath.row]
        cell.textLabel!.text = "\(item.firstName!) \(item.lastName!)"
        
        return cell
    }
    
    /**
    Table View Row Tapped Action
    We want to opens up the MediaURL in browser
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = studentLocations[indexPath.row]
        
        let url: NSURL = NSURL(string: item.mediaURL!)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    /**
    Table View number of rows
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations!.count;
    }
    
    /**
    Reload rows in table view with new studentLocations data
    */
    func reloadTableViewData() {
        dispatch_async( dispatch_get_main_queue() ) {
            self.studentLocationTableView.reloadData()
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
                self.studentLocations = results
                self.appDelegate.studentLocations = self.studentLocations
                
                if let handler: () -> Void = completionHandler {
                    handler()
                }
            }
        }
    }

}

