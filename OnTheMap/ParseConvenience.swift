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
    Post Student Location to Parse API

    :param: studentLocation
    :param: completionHandler
    */
	func postStudentLocation( studentLocation: StudentLocation, completionHandler: (success: Bool, error: NSError? ) -> Void ) {

        let jsonBody = [
            "uniqueKey": studentLocation.uniqueKey,
            "firstName": studentLocation.firstName!,
            "lastName": studentLocation.lastName!,
            "mapString": studentLocation.mapString!,
            "mediaURL": studentLocation.mediaURL!,
            "latitude": studentLocation.latitude!,
            "longitude": studentLocation.longitude!
        ]

		taskForPOSTMethod( Methods.StudentLocation, jsonBody: jsonBody as! [String : AnyObject]) { (result, error) -> Void in
            
            if let error = error {
                
                completionHandler(success: false, error: error)
                
            } else {
                
                if let createdAt = result.valueForKey(ParseClient.JSONResponseKey.CreatedAt) as? String {
                	completionHandler(success: true, error: nil)	
                } else {
                	completionHandler(success: false, error: NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocation"]))
                }
            
            }
        }

	}

}
