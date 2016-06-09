//
//  AudioPlayer.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/7/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import UIKit
import OpenGLES
import AudioToolbox

enum AudioPlayState{
    case ReadyToPlay
    case Playing
    case Pause
    case PlayFinished
    case PlayUnknown
}

//MARK - Notification


protocol AudioPlayerDelegate {
    func audioPlayer(player: AudioPlayer, buffer: [Float], bufferSize: UInt32, numberOfChanels: UInt32, audioFile: AudioFileManager)
}
class AudioPlayer: NSObject {
    var output: AudioOutput?
    var audioFile: AudioFileManager?
    var delegate: AudioPlayerDelegate?
    override init() {
        super.init()
        setup()
    }
    
    func playAudio(audioFile_: AudioFileManager) {
        audioFile = audioFile_
        output?.startPlayback()
    }
    
    func setup() {
        output = AudioOutput()
        output?.delegate = self
        output?.datasource = self
    }
    
    func play() {
        output?.startPlayback()
    }
    
    func pause() {
        output?.startPlayback()
    }
}

extension AudioPlayer: AudioOutputDelegate {
    func output(output: AudioOutput, playedAudio buffer: [Float], withBufferSize size: UInt32, numberOfChannels chanels: UInt32) {
        guard let del = delegate else {
            return
        }
        del.audioPlayer(self, buffer: buffer, bufferSize: size, numberOfChanels: chanels, audioFile: audioFile!)
    }
}

extension AudioPlayer: AudioOutputDataSource {
    func output(output: AudioOutput, shouldFillAudioBufferList audioBufferList: AudioBufferList, withNumerOfFrames frames: UInt32, timestamp tms: AudioTimeStamp) -> OSStatus {
        guard let audo = audioFile else {
            return noErr
        }
        let bufferSize: UnsafeMutablePointer<UInt32> = nil
        let eof: UnsafeMutablePointer<Bool> = nil
        audo.readFrame(frames, audoBufferList: audioBufferList, bufferSize: bufferSize, eof: eof)
        return noErr        
    }
}
