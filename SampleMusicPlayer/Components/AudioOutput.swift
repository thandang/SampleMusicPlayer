//
//  AudioOutput.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/7/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

struct AudioNodeInfo {
    var audioUnit: AudioUnit
    var node: AUNode
}

struct AudioOutputInfo {
    var converterNodeInfo: AudioNodeInfo
    var mixerNodeInfo: AudioNodeInfo
    var outputNodeInfo: AudioNodeInfo
    var graph: AUGraph
}

//MARK - Callback


//OSStatus EZOutputConverterInputCallback(void                       *inRefCon,
//                                        AudioUnitRenderActionFlags *ioActionFlags,
//                                        const AudioTimeStamp       *inTimeStamp,
//                                        UInt32					    inBusNumber,
//                                        UInt32					    inNumberFrames,
//                                        AudioBufferList            *ioData);

//------------------------------------------------------------------------------

//OSStatus EZOutputGraphRenderCallback(void                       *inRefCon,
//                                     AudioUnitRenderActionFlags *ioActionFlags,
//                                     const AudioTimeStamp       *inTimeStamp,
//                                     UInt32					     inBusNumber,
//                                     UInt32                      inNumberFrames,
//                                     AudioBufferList            *ioData);


class AudioOutput: NSObject {
    
    private var info: AudioOutputInfo?
    var datasource: AudioOutputDataSource?
    var delegate: AudioOutputDelegate?
    
    override init() {
        super.init()
        setup()
    }
    
    init(delegate_: AudioOutputDelegate, datasource_: AudioOutputDataSource) {
        super.init()
        delegate = delegate_
        datasource = datasource_
        setup()
        
    }
    
    func setup() {
        
    }
    
    func startPlayback() {
//        AUGraphStart(info.)
    }
    
    func stopPlayback() {
        
    }
    
    
    func connectOUtputOfSourceNode(sourceNode: AUNode, sourceNodeOutputBus: UInt32, destinateNode: AUNode, destinateNodeBus: UInt32, inGraph: AUGraph) -> OSStatus {
        return -1
    }
    
}

protocol AudioOutputDataSource {
    func output(output: AudioOutput, shouldFillAudioBufferList audioBufferList: UnsafePointer<AudioBufferList>, withNumerOfFrames frames: UInt32, timestamp tms: UnsafePointer<AudioTimeStamp>) -> OSStatus
    
}

protocol AudioOutputDelegate {
    func output(output: AudioOutput, playedAudio buffer: Float, withBufferSize size: UInt32, numberOfChannels chanels: UInt32)
}
