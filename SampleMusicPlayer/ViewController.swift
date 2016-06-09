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

    
    @IBOutlet weak var bandsVIew: AudioPlotView!
    var audioPlayer: AudioPlayer!
    var audioFileManager: AudioFileManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSession() {
        let session = AVAudioSession()
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        try! session.setActive(true)
        
        bandsVIew.backgroundColor = UIColor(red: 0.2, green: 0.1, blue: 0.1, alpha: 1.0)
        bandsVIew.myColor = UIColor(red: 56.0/255, green: 90.0/255, blue: 12.0/255, alpha: 1.0)
        bandsVIew.souldFill = true
        
        //
        // Create the audio player
        //
        audioPlayer = AudioPlayer()
        audioPlayer.delegate = self
        try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        let url = NSBundle.mainBundle().pathForResource("Samba-drum-beat-115-bpm", ofType: "wav")
        guard let ul = url else {
            return
        }
        audioFileManager = AudioFileManager(url: NSURL(fileURLWithPath: ul))
        
        audioPlayer.audioFile = audioFileManager
    }
}

extension ViewController: AudioPlayerDelegate {
    func audioPlayer(player: AudioPlayer, buffer: [Float], bufferSize: UInt32, numberOfChanels: UInt32, audioFile: AudioFileManager) {
       
        dispatch_async(dispatch_get_main_queue()) { 
            [unowned self] in
            self.bandsVIew.updateBuffer(buffer, bufferSize: bufferSize)
        }
    }
}

