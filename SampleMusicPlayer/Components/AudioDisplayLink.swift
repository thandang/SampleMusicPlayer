//
//  AudioDisplayLink.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/7/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import QuartzCore

class AudioDisplayLink: NSObject {
    var delegate: AudioDisplayLinkDelegate?
    var displayLink: CADisplayLink?
    var isStopped: Bool = false
    init(delegate: AudioDisplayLinkDelegate) {
        super.init()
        self.delegate = delegate
        setup()
    }
    
    func setup() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func update() {
        guard let del = delegate else {
            return
        }
        if !isStopped {
            del.displayLinkNeedDisplay(self)
        }
    }
    
    /**
     Start looping drawing
     */
    func start() {
        if let _ = displayLink {
            displayLink?.paused = false
            isStopped = false
        }
    }
    
    /**
     Stop drawing
     */
    func stop() {
        if let _ = displayLink {
            displayLink?.paused = true
            isStopped = true
        }
    }
    
    deinit {
        if let _ = displayLink {
            displayLink?.invalidate() //To makesure no run loop after parent object has been destroy
        }
    }
}

protocol AudioDisplayLinkDelegate: NSObjectProtocol {
    func displayLinkNeedDisplay(link: AudioDisplayLink);
}