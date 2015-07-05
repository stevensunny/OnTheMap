//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Steven on 5/07/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    struct Constants {
        static let BaseURLSecure: String = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        
        // For login
        static let Session = "session"
        
        // For getting user data
        static let UsersID = "users/{id}"
    }
    
    struct JSONBody {
        
        // The default parameter (dictionary) wrapper name
        static let Wrapper = "udacity"
        
        // For login
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        
        // Login Response - Session
        static let Session = "session"
        static let SessionID = "id"
        static let SessionExpiry = "expiry"
        
        // General
        static let Error = "error"
        static let Status = "status"
        
    }
    
}