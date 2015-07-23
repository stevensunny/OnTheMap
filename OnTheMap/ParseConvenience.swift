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

}
