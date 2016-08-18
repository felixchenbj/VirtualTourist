//
//  Constants.swift
//  VirtualTourist
//
//  Created by felix on 8/18/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit


struct Constants {
    // MARK: URLs
    static let ApiScheme = "http"
    static let ApiSecureScheme = "https"
    
    struct HTTPMethod {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
    
    struct Flicker {
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        
        static let PhotoSearch = "flickr.photos.search"
        static let ApiKey = ""
        
        static let Extras = "url_m"
        static let Format = "json"
        
    }
}

extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}