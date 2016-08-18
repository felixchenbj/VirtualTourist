//
//  Logger.swift
//  VirtualTourist
//
//  Created by felix on 8/18/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import Foundation

struct Logger {
    static let log: XCGLogger = {
        let log = XCGLogger.defaultInstance()
        log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: false, writeToFile: nil)
        log.xcodeColorsEnabled = true
        log.xcodeColors = [
            .Verbose: .lightGrey,
            .Debug: .darkGrey,
            .Info: .darkGreen,
            .Warning: .orange,
            .Error: .red,
            .Severe: .whiteOnRed
        ]
        
        return log
    }()
}

