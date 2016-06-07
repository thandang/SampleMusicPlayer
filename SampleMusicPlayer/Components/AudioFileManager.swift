//
//  AudioFileManager.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/7/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import AudioToolbox

class AudioFileManager: NSObject {
    var url: String?
    var datasource: AudioFileDataSource?
    var delegate: AudioFileDelegate?
    
    init(url: NSURL?) {
        super.init()
    }
    
    init(url: NSURL?, delegate: AudioFileDelegate?) {
        super.init()
    }
    
    
    func readFrame(frames: UInt32, audoBufferList bufferList: AudioBufferList, bufferSize size: UInt32, eof: Bool) {
        
    }
}

protocol AudioFileDelegate {
    
}

protocol AudioFileDataSource {
    
}

