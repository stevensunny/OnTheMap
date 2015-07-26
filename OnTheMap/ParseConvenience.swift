//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Steven on 11/07/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import Foundation
import UIKit

extension ParseClient {
	
	/**
	Get existing student locations from Parse API
	
	:param: Parameters
	*/
	func getStudentLocations( limit: Int, completionHandler: ( results: [StudentLocation]?, error: NSError? ) -> Void ) {

		let parameters = [
			"limit" : limit
		]

		// Make the GET request
		taskForGETMethod( Methods.StudentLocation, parameters: parameters ) {
			JSONResult, error in 

			if let error = error {
				completionHandler( results: nil, error: error )
			} else {

				// Parse the results into StudentLocation object
				if let results = JSONResult.valueForKey( ParseClient.JSONResponseKey.Wrapper ) as? [[String: AnyObject]] {

					// Success, return the student locations array
					var locations = StudentLocation.studentLocationsFromResult( results )
					completionHandler( results: locations, error: nil )
				} else {

					// Return error
					completionHandler( results: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"] ) )

				}
				
			}

		}
	}
    
    /**
    Check Parse for existing record of StudentLocation of the current user and get the objectId if it exists.
    
    :param: uniqueKey
    :param: completionHandler
    */
    func getMyLocationObjectId( uniqueKey: String, completionHandler: (success: Bool, objectId: String?, error: NSError? ) -> Void ) {
        
        let parameters = [
            "where": "{\"uniqueKey\":\"\(uniqueKey)\"}"
        ]
        
        taskForGETMethod( Methods.StudentLocation, parameters: parameters) { (result, error) -> Void in
            
            if let error = error {
                
                completionHandler(success: false, objectId: nil, error: error)
                
            } else {
                
                if let results = result.valueForKey( ParseClient.JSONResponseKey.Wrapper ) as? [[String: AnyObject]] {
                    
                    // Success, return the student locations array
                    var locations = StudentLocation.studentLocationsFromResult( results )
                    completionHandler( success: true, objectId: locations[0].objectId, error: nil )
                    
                } else {
                    
                    // Error parsing,
                    completionHandler(success: false, objectId: nil, error: NSError(domain: "getMyLocationObjectId parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMyLocationObjectId"] ))
                    
                }
                
            }
            
        }
        
    }
    
	/**
    Post Student Location to Parse API

    :param: studentLocation
    :param: completionHandler
    */
	func postStudentLocation( studentLocation: StudentLocation, completionHandler: (success: Bool, error: NSError? ) -> Void ) {

        self.getMyLocationObjectId( studentLocation.uniqueKey, completionHandler: { (success, objectId, error) -> Void in
            
            var jsonBody: [String: AnyObject] = [
                "uniqueKey": studentLocation.uniqueKey,
                "firstName": studentLocation.firstName!,
                "lastName": studentLocation.lastName!,
                "mapString": studentLocation.mapString!,
                "mediaURL": studentLocation.mediaURL!,
                "latitude": studentLocation.latitude!,
                "longitude": studentLocation.longitude!
            ]
            
            var httpMethod: String = "POST"
            var mutableMethod = Methods.StudentLocation
            
            if let objectId = objectId {
                httpMethod = "PUT"
                mutableMethod = "\(mutableMethod)/\(objectId)"
            }
            
            self.taskForMethod( httpMethod: httpMethod, method: mutableMethod, jsonBody: jsonBody ) { (result, error) -> Void in
                
                if let error = error {
                    
                    completionHandler(success: false, error: error)
                    
                } else {
                    
                    if let createdAt = result.valueForKey(ParseClient.JSONResponseKey.CreatedAt) as? String {
                        completionHandler(success: true, error: nil)
                    } else if let updatedAt = result.valueForKey(ParseClient.JSONResponseKey.UpdatedAt) as? String {
                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocation"]))
                    }
                    
                }
            }

        })
        
	}

}
