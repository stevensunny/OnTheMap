//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Steven on 5/07/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    /**
    Authenticate with Udacity Client
    
    :param: username          The username entered in textfield
    :param: password          The password entered in password field
    :param: completionHandler Indicate whether the request is a success, and if not, what is the error
    */
    func authenticateWithEmail(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        self.getSessionIDAndUserID(username, password: password) {
            (success, sessionID, userID, errorString) in
            
            if let error = errorString {
                
                completionHandler(success: false, errorString: error)
                
            } else {
                
                self.sessionID = sessionID
                self.userID = userID
                
                self.getUserData(self.userID!, completionHandler: { (success, userData, errorString) -> Void in
                    
                    if let error = errorString {
                        
                        completionHandler(success: false, errorString: error)
                        
                    } else {
                        
                        
                        self.firstName = userData![UdacityClient.JSONResponseKeys.FirstName] as? String
                        self.lastName = userData![UdacityClient.JSONResponseKeys.LastName] as? String
                        completionHandler(success: true, errorString: nil)
                        
                    }
                    
                })
                
            }
            
        }
    }
    
    /**
    Logout
    
    :param: completionHandler
    */
    func logout(completionHandler: (success: Bool, errorString: String?) -> Void) {

        taskForDELETEMethod(UdacityClient.Methods.Session) {
            result, error in 

            if let error = error {
                completionHandler(success: false, errorString: "Logout Failed")
            } else {
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
    /**
    Get session
    
    :param: username
    :param: password
    :param: completionHandler
    */
    func getSessionIDAndUserID(username: String, password: String, completionHandler:(success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        // Set the jsonBody
        var jsonBody = [
            UdacityClient.JSONBody.Wrapper: [
                UdacityClient.JSONBody.Username: username,
                UdacityClient.JSONBody.Password: password
            ]
        ]
        
        // Make the request
        taskForPOSTMethod(UdacityClient.Methods.Session, jsonBody: jsonBody) { (result, error) -> Void in
            if let error = error {
                
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed")
                
            } else {
                
                if let session = result.valueForKey(UdacityClient.JSONResponseKeys.Session) as? [String: AnyObject],
                    let account = result.valueForKey(UdacityClient.JSONResponseKeys.Account) as? [String: AnyObject] {
                    
                    let sessionID = session[UdacityClient.JSONResponseKeys.SessionID] as! String
                    let userID = account[UdacityClient.JSONResponseKeys.AccountKey] as! String
                    completionHandler(success: true, sessionID: sessionID, userID: userID, errorString: nil)
                    
                } else {
                    
                    completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Invalid username and password")
                }
                
            }
        }
    }

    /**
    Get User Data from the given UserID
    
    :param: userID
    :param: completionHandler
    */
    func getUserData(userID: String, completionHandler: (success: Bool, userData:[String: AnyObject]?, errorString: String?) -> Void) {
        
        var mutableMethod: String = UdacityClient.Methods.UsersID
        mutableMethod = UdacityClient.substituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
        
        taskForGETMethod(mutableMethod, completionHandler: { (result, error) -> Void in
            if let error = error {

                completionHandler(success: false, userData: nil, errorString: "Get User Data Failed. Connection interrupted")
                
            } else {
                
                if let userData = result.valueForKey(UdacityClient.JSONResponseKeys.UserWrapper) as? [String: AnyObject] {
                    completionHandler(success: true, userData: userData, errorString: nil)
                } else {
                    completionHandler(success: false, userData: nil, errorString: "Get User Data Failed. Results not found")
                }
                
            }
        })
        
    }
}