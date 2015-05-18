//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Nicholas Schirmer on 5/15/15.
//  Copyright (c) 2015 Shiny New Software, LLC. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL!
    var title: String!
    
    override init() {
        super.init()
    }
    
    init(filePathUrl: NSURL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
        
        super.init()
    }
}