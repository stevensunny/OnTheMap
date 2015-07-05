//
//  UdacitySession.swift
//  OnTheMap
//
//  Created by Steven on 5/07/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import Foundation

struct UdacitySession {
    
    var accountRegistered = false
    var sessionID: String? = nil
    
    init(dictionary: [String: AnyObject]) {
        
        let account = dictionary["account"] as! [String: AnyObject]
        accountRegistered = account["registered"] as! Bool
        
        let session = dictionary["session"] as! [String: AnyObject]
        sessionID = (account["id"] as! String)
        
    }
    
}