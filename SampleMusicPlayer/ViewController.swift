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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupSession()
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
        view.addSubview(bandsView)
        bandsView.myColor = UIColor(red: 56.0/255, green: 90.0/255, blue: 12.0/255, alpha: 1.0)
        
        
        //
        // Create the audio player
        //
//        audioPlayer = AudioPlayer()
//        audioPlayer.delegate = self
        ezAudioPlayer = EZAudioPlayer(delegate: self)
        try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        let url = NSBundle.mainBundle().pathForResource("Samba-drum-beat-115-bpm", ofType: "wav")
        guard let ul = url else {
            return
        }
        ezAudioFile = EZAudioFile(URL: NSURL(fileURLWithPath: ul))
        guard let file = ezAudioFile else {
            return
        }
        
        ezAudioPlayer.audioFile = file
        ezAudioPlayer.play()
        
//        audioFileManager = AudioFileManager(url: NSURL(fileURLWithPath: ul))
//        audioPlayer.audioFile = audioFileManager
//        audioPlayer.play()
    }
}

extension ViewController: EZAudioPlayerDelegate {
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.bandsView.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
}

extension ViewController: AudioPlayerDelegate {
    func audioPlayer(player: AudioPlayer, buffer: [Float], bufferSize: UInt32, numberOfChanels: UInt32, audioFile: AudioFileManager) {
       
//        dispatch_async(dispatch_get_main_queue()) { 
//            [unowned self] in
//            self.bandsVIew.updateBuffer(buffer, bufferSize: bufferSize)
//        }
    }
}

