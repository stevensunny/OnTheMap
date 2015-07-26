//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Steven on 6/07/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import Foundation

extension ParseClient {
    
    struct Constants {
        static let BaseURLSecure = "https://api.parse.com/1/classes/"
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct Methods {
        static let StudentLocation = "StudentLocation"
    }
    
    struct JSONResponseKey {
        // StudentLocation array wrapper
        static let Wrapper = "results"

        // StudentLocation keys
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"

        // Post StudentLocation
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
}