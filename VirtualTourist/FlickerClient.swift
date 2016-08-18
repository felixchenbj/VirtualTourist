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
    
    func searchPhotos() -> [String]{
        
        
        return []
    }
    
    
}
