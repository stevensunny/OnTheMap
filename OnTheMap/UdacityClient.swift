//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Steven on 5/07/2015.
//  Copyright (c) 2015 Horsemen. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    var session: NSURLSession
    
    var sessionID: String? = nil
    var userID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Request Methods
    
    /**
    Make a GET request to Udacity API
    
    :param: method
    :param: parameters
    :param: completionHandler
    */
    func taskForGETMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build URL and configure URLRequest
        let urlString = Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // Make the request
        let task = session.dataTaskWithRequest(request) {
            data, response, downloadError in
            
            // Parse response
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                UdacityClient.parseJSONWithCompletionHandler( data, completionHandler: completionHandler )
            }
            
        }
        
        // Resume task
        task.resume()
        
        return task
    }
    
    /**
    Make a POST request to Udacity API
    
    :param: method
    :param: jsonBody
    :param: completionHandler
    */
    func taskForPOSTMethod(method: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /**
    Make a DELETE request to Udacity API
    
    :param: method
    :param: completionHandler
    */
    func taskForDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build the URL and configure the Request
        let urlString = Constants.BaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }

        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Helper Methods
    
    /**
    Given raw JSON, return a usable Foundation object
    
    :param: data              Raw JSON data
    :param: completionHandler
    */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        /* Skip first 5 characters from the response */
        let data = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /**
    Given a dictionary of parameters, convert to a string for a url
    
    :param: parameters Parameters to be converted
    
    :returns: String containing the parameters url
    */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    /**
    Substitute the key for the value that is contained within the method name
    
    :param: method
    :param: key
    :param: value
    */
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}