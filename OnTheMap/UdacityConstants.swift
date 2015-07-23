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
        static let SignUpURL: String = "https://www.udacity.com/account/auth#!/signup"
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
        
        // Login Response - Account
        static let Account = "account"
        static let AccountKey = "key"
        
        // General
        static let Error = "error"
        static let Status = "status"

        // User data
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        
    }
    
}