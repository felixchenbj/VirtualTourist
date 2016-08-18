//
//  FlickerClient.swift
//  VirtualTourist
//
//  Created by felix on 8/18/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import Foundation

class FlickerClient {
    
    private static var flickerClient = FlickerClient()
    static func sharedFlickerClient() -> FlickerClient {
        return flickerClient
    }
    
    private init () {
        
    }
    
    func searchPhotos(latitude: Double, longitude: Double, completionHandler: (info: String, results: [String]?, success: Bool) -> Void) {
        
        var parameters = [String:AnyObject!] ()
        parameters["method"] = Constants.Flicker.PhotoSearch
        parameters["api_key"] = Constants.Flicker.ApiKey
        
        parameters["lat"] = latitude
        parameters["lon"] = longitude
        
        
        parameters["extras"] = Constants.Flicker.Extras
        parameters["format"] = Constants.Flicker.Format
        
        parameters["nojsoncallback"] = 1
        
        HTTPHelper.HTTPRequest(Constants.ApiSecureScheme,
                               host: Constants.Flicker.ApiHost,
                               path: Constants.Flicker.ApiPath,
                               parameters: parameters ) { (data, statusCode, error) in
                                
                                guard (error == nil) else {
                                    completionHandler(info: "There was an error with your request.", results: nil, success: false)
                                    return
                                }
                                
                                if let data = data {
                                    let json = JSON(data: data)
                                    if let stat = json["stat"].string {
                                        if stat == "ok" {
                                            if let photos:Array<JSON> = json["photos"]["photo"].arrayValue {
                                                for photo in photos {
                                                    print(photo["url_m"])
                                                }
                                            }
                                        } else {
                                            completionHandler(info: "Response status is not ok.", results: nil, success: false)
                                            return
                                        }
                                    }
                                }
        }
    }
    
}
