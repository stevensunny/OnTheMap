//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Steven on 6/07/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import Foundation

struct StudentLocation {
    
    var objectId: String = ""
    var uniqueKey: String = ""
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil

    init(dictionary: [String: AnyObject]) {
        
        objectId = dictionary[ParseClient.JSONResponseKey.ObjectId] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKey.UniqueKey] as! String
        firstName = dictionary[ParseClient.JSONResponseKey.FirstName] as? String
        lastName = dictionary[ParseClient.JSONResponseKey.LastName] as? String
        mapString = dictionary[ParseClient.JSONResponseKey.MapString] as? String
        mediaURL = dictionary[ParseClient.JSONResponseKey.MediaURL] as? String
        latitude = dictionary[ParseClient.JSONResponseKey.Latitude] as? Double
        longitude = dictionary[ParseClient.JSONResponseKey.Longitude] as? Double
        
    }
    
    // MARK: Helper Methods

    /**
    Return array of StudentLocation objects with the given array of dictionaries
    
    :param: results         Array of student location dictionaries
    */
    static func studentLocationsFromResult( results: [[String: AnyObject]] ) -> [StudentLocation] {
        var studentLocations = [StudentLocation]()
        for result in results {
            studentLocations.append( StudentLocation( dictionary: result ) )
        } 

        return studentLocations
    }
    
}