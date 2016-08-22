//
//  HTTPHelper.swift
//  OnTheMap
//
//  Created by felix on 8/15/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import Foundation

struct HTTPHelper {
    static func HTTPRequest(schema: String, host: String, path: String, pathExtension: String? = nil, HTTPMethod: String = Constants.HTTPMethod.GET, headers: [String: String]? = nil, parameters: [String:AnyObject]? = nil, HTTPBody: String? = nil, completionHandler: (NSData?, Int?, NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: buildURL(schema, host: host, path: path, pathExtension: pathExtension, HTTPMethod: HTTPMethod, parameters: parameters))
        
        request.HTTPMethod = HTTPMethod
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let HTTPBody = HTTPBody {
            request.HTTPBody = HTTPBody.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            completionHandler(data, ((response as? NSHTTPURLResponse)?.statusCode) , error)
        }
        
        task.resume()
        return task
    }
    
    static func buildURL(schema: String, host: String, path: String, pathExtension: String?, HTTPMethod: String, parameters: [String:AnyObject]?) -> NSURL {
        let components = NSURLComponents()
        components.scheme = schema
        components.host = host
        components.path = path + (pathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        //Logger.log.info("\(components.URL!)")
        return components.URL!
    }
    
    static func downloadImageFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }

}