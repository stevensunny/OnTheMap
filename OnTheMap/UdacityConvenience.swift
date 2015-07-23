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
    Authenticate with Udacity Client
    
    :param: username          The username entered in textfield
    :param: password          The password entered in password field
    :param: completionHandler Indicate whether the request is a success, and if not, what is the error
    */
    func authenticateWithEmail(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        self.getSessionID(username, password: password) {
            (success, sessionID, errorString) in
            
            if success {
                self.sessionID = sessionID
                self.userID =
            }
            completionHandler(success: success, errorString: errorString)
        }
    }
    
    func getSession(username: String, password: String, completionHandler:(success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
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
                
                completionHandler(success: false, sessionID: nil, errorString: "Login Failed")
                
            } else {
                
                if let session = result.valueForKey(UdacityClient.JSONResponseKeys.Session) as? [String: String] {
                    
                    let sessionID = session[UdacityClient.JSONResponseKeys.SessionID]
                    completionHandler(success: true, sessionID: sessionID, errorString: nil)
                    
                } else {
                    
                    completionHandler(success: false, sessionID: nil, errorString: "Login Failed, email or password ")
                }
                
                
            }
        }
    }
}