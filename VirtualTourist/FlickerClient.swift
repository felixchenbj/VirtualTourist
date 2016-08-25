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
    
    func getRandomPhotos(latitude: Double, longitude: Double, page:Int = -1, completionHandler: ((info: String, results: [String]?, success: Bool) -> Void)?) {
        // get page count
        searchPhotos(latitude, longitude: longitude, page: page, completionHandler: { (info, pageCount, results, success) in
            if success {
                Logger.log.debug("Page count: \(pageCount)")
                
                // Fliker Api would only return at most the first 4,000 results
                let maxPageNum = 4000/Constants.Flicker.PhotoPerPage
                let fixedPageCount = pageCount > maxPageNum ? maxPageNum : pageCount
                
                if fixedPageCount > 0 {
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(fixedPageCount)))
                    Logger.log.debug("Random page index: \(randomPhotoIndex)")
                    
                    self.searchPhotos(latitude, longitude: longitude, page: randomPhotoIndex, completionHandler: { (info, pageCount, results, success) in
                        if let completionHandler = completionHandler {
                            completionHandler(info: info, results: results, success: success)
                        }
                    })
                }
            }
        })
    }
    
    func searchPhotos(latitude: Double, longitude: Double, page:Int = -1, completionHandler: ((info: String, pageCount: Int , results: [String]?, success: Bool) -> Void)?) {
        
        var parameters = [String:AnyObject!] ()
        parameters["method"] = Constants.Flicker.PhotoSearch
        parameters["api_key"] = Constants.Flicker.ApiKey
        
        parameters["lat"] = latitude
        parameters["lon"] = longitude
        
        parameters["extras"] = Constants.Flicker.Extras
        parameters["format"] = Constants.Flicker.Format
        
        parameters["nojsoncallback"] = 1
        
        parameters["per_page"] = Constants.Flicker.PhotoPerPage
        
        if page > 0 {
            parameters["page"] = page
        }
        
        var pageCount = 0
        var results = [String]()
        
        HTTPHelper.HTTPRequest(Constants.ApiSecureScheme,
                               host: Constants.Flicker.ApiHost,
                               path: Constants.Flicker.ApiPath,
                               parameters: parameters ) { (data, statusCode, error) in
                                
                                guard (error == nil) else {
                                    if let completionHandler = completionHandler {
                                        completionHandler(info: "There was an error with your request.", pageCount: pageCount, results: nil, success: false)
                                    }
                                    return
                                }
                                
                                /* GUARD: Did we get a successful 2XX response? */
                                guard statusCode >= 200 && statusCode <= 299 else {
                                    if let completionHandler = completionHandler {
                                        completionHandler(info: "Your request returned a status code other than 2xx!", pageCount: pageCount, results: nil, success: false)
                                    }
                                    return
                                }
                                
                                if let data = data {
                                    let json = JSON(data: data)
                                    
                                    if let stat = json["stat"].string {
                                        if stat == "ok" {
                                            if let photos:Array<JSON> = json["photos"]["photo"].arrayValue {
                                                for photo in photos {
                                                    results.append(photo["url_m"].stringValue)
                                                }
                                            }
                                            
                                            if let count = json["photos"]["pages"].int {
                                                pageCount = count
                                            }
                                            
                                            if let completionHandler = completionHandler {
                                                completionHandler(info: "Get photos successfully.", pageCount: pageCount, results: results, success: true)
                                                return
                                            }
                                        } else {
                                            if let completionHandler = completionHandler {
                                                let message = json["message"].string ?? "Response status is not ok."
                                                completionHandler(info: message, pageCount: pageCount, results: nil, success: false)
                                            }
                                            return
                                        }
                                    }
                                }
        }
    }
    
}
