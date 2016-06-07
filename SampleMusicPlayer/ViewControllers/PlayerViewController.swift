//
//  PlayerViewController.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/6/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import UIKit
import GLKit
import OpenGLES
import AVFoundation

class PlayerViewController: GLKViewController {
    override func viewDidLoad() {
        //start buffer here
    }
    
    override func didReceiveMemoryWarning() {
        //Handle for low memory needed
    }
    
    /**
     Draw in main view
     
     - parameter view: current view
     - parameter rect: current rect
     */
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        
    }
    
    func startPlayingAudio() {
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback) //throws error later
        try! session.setActive(true)

//        
//        //
//        // Customizing the audio plot's look
//        //
//        self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.816 green: 0.349 blue: 0.255 alpha: 1];
//        self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
//        self.audioPlot.plotType        = EZPlotTypeBuffer;
//        self.audioPlot.shouldFill      = YES;
//        self.audioPlot.shouldMirror    = YES;
//        
//        NSLog(@"outputs: %@", [EZAudioDevice outputDevices]);
//        
//        //
//        // Create the audio player
//        //
//        self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
//        self.player.shouldLoop = YES;
//        
//        //
//        // Override the output to the speaker
//        //
//        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
//        if (error)
//        {
//            NSLog(@"Error overriding output to the speaker: %@", error.localizedDescription);
//        }
//        
//        //
//        // Customize UI components
//        //
//        self.rollingHistorySlider.value = (float)[self.audioPlot rollingHistoryLength];
//        
//        //
//        // Listen for EZAudioPlayer notifications
//        //
//        [self setupNotifications];
//        
//        /*
//         Try opening the sample file
//         */
//        [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
    }
}

extension PlayerViewController: GLKViewControllerDelegate {
    /**
     Handle for update frame, render frame. Remember for clear frame every time draw new
     
     - parameter controller: it's current viewcontroller
     */
    func glkViewControllerUpdate(controller: GLKViewController) {
//        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
//        glClear(GL_DEPTH_BUFFER_BIT)
//        glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    }
    
    /**
     Handle for pause update farme
     
     - parameter controller: current viewcontroller
     - parameter pause:      check pause status
     */
    func glkViewController(controller: GLKViewController, willPause pause: Bool) {
        
    }
}
