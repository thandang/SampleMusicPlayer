//
//  ViewController.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/6/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class ViewController: UIViewController {

    weak var bandsView: AudioPlotView!
    var audioPlayer: AudioPlayer!
    var audioFileManager: AudioFileManager!
    var ezAudioFile: EZAudioFile!
    var ezAudioPlayer: EZAudioPlayer!
    let defaultPlayer: Bool = true
    
    var resource: [String] = []
    var indexPlay: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let url = NSBundle.mainBundle().pathForResource("Samba-drum-beat-115-bpm", ofType: "wav")
        let url2 = NSBundle.mainBundle().pathForResource("winamp", ofType: "wav")
        let url3 = NSBundle.mainBundle().pathForResource("Fill", ofType: "wav")
        let url4 = NSBundle.mainBundle().pathForResource("Basic_Beat", ofType: "wav")
//        if let _ = url {
//            resource.append(url!)
//        }
        if let _ = url2 {
            resource.append(url2!)
        }
        if let _ = url3 {
            resource.append(url3!)
        }
        if let _ = url4 {
            resource.append(url4!)
        }
        setupSession()
    }

    deinit {
        bandsView.displayLink?.stop()
        bandsView.clear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        bandsView.displayLink?.stop()
        bandsView.clear()
    }
    
    func setupSession() {
        let session = AVAudioSession()
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        try! session.setActive(true)
        
        //TmpBand
        let context = EAGLContext(API: .OpenGLES2)
        bandsView = AudioPlotView(frame: view.frame, context: context)
        if let _ = bandsView {
            view.addSubview(bandsView!)
        }
        
//        bandsView.myColor = UIColor(red: 56.0/255, green: 90.0/255, blue: 12.0/255, alpha: 1.0)
        
        try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        
        //
        // Create the audio player
        //
        if defaultPlayer {
          ezAudioPlayer = EZAudioPlayer(delegate: self)
            ezAudioPlayer.shouldLoop = false
            indexPlay = 0 //initialize
            ezAudioFile = EZAudioFile(URL: NSURL(fileURLWithPath: resource[indexPlay]))
            guard let file = ezAudioFile else {
                return
            }
            
            ezAudioPlayer.audioFile = file
            ezAudioPlayer.play()
        } else {
            audioPlayer = AudioPlayer()
            audioPlayer.delegate = self
            audioFileManager = AudioFileManager(url: NSURL(fileURLWithPath: resource.first!))
            audioPlayer.audioFile = audioFileManager
            audioPlayer.play()
        }
    }
}

extension ViewController: EZAudioPlayerDelegate {
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.bandsView.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, reachedEndOfAudioFile audioFile: EZAudioFile!) {
        //Start to new one
        ezAudioFile = nil
        indexPlay += 1
        if indexPlay > 2 {
            indexPlay = 0;
        }
        ezAudioFile = EZAudioFile(URL: NSURL(fileURLWithPath: resource[indexPlay]))
        guard let file = ezAudioFile else {
            return
        }
        
        ezAudioPlayer.audioFile = file
        ezAudioPlayer.play()
    }
}

extension ViewController: AudioPlayerDelegate {
    func audioPlayer(player: AudioPlayer, buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, bufferSize: UInt32, numberOfChanels: UInt32, audioFile: AudioFileManager) {
       
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.bandsView.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
}

