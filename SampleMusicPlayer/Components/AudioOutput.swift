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
    var audioUnit: AudioUnit?
    var node: AUNode?
}

struct AudioOutputInfo {
    var converterNodeInfo: AudioNodeInfo?
    var mixerNodeInfo: AudioNodeInfo?
    var outputNodeInfo: AudioNodeInfo?
    var graph: AUGraph?
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

typealias OutputGraphRenderCallback = (inRedCon: UnsafeMutablePointer<Void>, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimestamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus


typealias OutputConverterInputCallback = (inRedCon: UnsafeMutablePointer<Void>, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimestamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus

class AudioOutput: NSObject {
    
    private var info: AudioOutputInfo?
    var datasource: AudioOutputDataSource?
    var delegate: AudioOutputDelegate?
    
    let OutputMaximumFramesPerSlide: UInt32 = 4096
    let OutputDefaultSampleRate: Float64 = 44100.0
    
    var grapRenderCallback: OutputGraphRenderCallback = { red, actionFlags, timestamp, busNumber, numberFrames, ioData in
        
        return noErr
    }
    
    var converterInputCallback: OutputConverterInputCallback = { red, actionFlags, timestamp, busNumber, numberFrames, ioData in
        
        return noErr
    }
        
    
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
        info = AudioOutputInfo()
        memset(&info, 0, sizeof(AudioOutputInfo))
        var graph_ = info?.graph
        
        if let _ = graph_ {
            NewAUGraph(&graph_!)
        }
        
        var converterDescription: AudioComponentDescription = AudioComponentDescription()
        
        converterDescription.componentType = kAudioUnitType_FormatConverter;
        converterDescription.componentSubType = kAudioUnitSubType_AUConverter;
        converterDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        var convertInfo = info?.converterNodeInfo
        if let _ = convertInfo {
            AUGraphAddNode((info?.graph)!, &converterDescription, &(convertInfo!.node)!)
        }
        
        
        //
        // Add mixer node
        //
        var mixerDescription: AudioComponentDescription = AudioComponentDescription()
        mixerDescription.componentType = kAudioUnitType_Mixer;
        mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
        
        mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        var mixerInfo = info?.mixerNodeInfo
        if let _ = graph_, _ = mixerInfo {
            AUGraphAddNode(graph_!, &mixerDescription, &(mixerInfo!.node)!)
        }
        
        
        //
        // Add output node
        //
        var outputDescription: AudioComponentDescription = AudioComponentDescription()
        outputDescription.componentType = kAudioUnitType_Output
        outputDescription.componentSubType = kAudioUnitSubType_RemoteIO
        outputDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        var outputInfo = info?.outputNodeInfo
        if let _ = graph_, _ = outputInfo {
            AUGraphAddNode(graph_!, &outputDescription, &(outputInfo!.node)!)
        }
        
        //
        // Open the graph
        //
        AUGraphOpen((info?.graph)!)
        
        //
        // Make node connections
        //
        
        let status =  connectOUtputOfSourceNode((convertInfo!.node)!, sourceNodeOutputBus: 0, destinateNode: (mixerInfo!.node)!, destinateNodeBus: 0, inGraph: graph_!)
        
        
        //
        // Connect mixer to output
        //
        AUGraphConnectNodeInput(graph_!, (mixerInfo!.node)!, 0, (outputInfo!.node)!, 0)
        
        //
        // Get the audio units
        //
        
        AUGraphNodeInfo(graph_!, (convertInfo!.node)!, &converterDescription, &(convertInfo!.audioUnit)!)
        

        AUGraphNodeInfo(graph_!, (mixerInfo!.node)!, &mixerDescription, &(mixerInfo!.audioUnit)!)
        
        AUGraphNodeInfo(graph_!, (outputInfo!.node)!, &outputDescription, &(outputInfo!.audioUnit)!)
        
        
        //
        // Add a node input callback for the converter node
        //
        var  converterCallback: AURenderCallbackStruct = AURenderCallbackStruct(inputProc: converterInputCallback, inputProcRefCon: self)
//        converterCallback.inputProc = EZOutputConverterInputCallback;
//        converterCallback.inputProcRefCon = (__bridge void *)(self);
        AUGraphSetNodeInputCallback(graph_!, (convertInfo!.node)!, 0, &converterCallback)
        
        //
        // Set stream formats
        //
//        [self setClientFormat:[self defaultClientFormat]];
//        [self setInputFormat:[self defaultInputFormat]];
        
        //
        // Use the default device
        //
//        EZAudioDevice *currentOutputDevice = [EZAudioDevice currentOutputDevice];
//        [self setDevice:currentOutputDevice];
        
        //
        // Set maximum frames per slice to 4096 to allow playback during
        // lock screen (iOS only?)
        //
        var maximumFramesPerSlice = OutputMaximumFramesPerSlide
        AudioUnitSetProperty((mixerInfo!.audioUnit)!, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maximumFramesPerSlice, maximumFramesPerSlice)
        
        
        //
        // Initialize all the audio units in the graph
        //
        AUGraphInitialize(graph_!)
        
        //
        // Add render callback
        //
//        AudioUnitAddRenderNotify((mixerInfo!.audioUnit)!, OutputGraphRenderCallback, self)
        
    }
    
    func startPlayback() {
//        AUGraphStart(info.)
    }
    
    func stopPlayback() {
        
    }
    
    
    func connectOUtputOfSourceNode(sourceNode: AUNode, sourceNodeOutputBus: UInt32, destinateNode: AUNode, destinateNodeBus: UInt32, inGraph: AUGraph) -> OSStatus {
        return -1
    }
    
    //MARK - Callback implementation
//    func OutputConverterInputCallbac(inRedCon: Void, ioActionFlags: AudioUnitRenderActionFlags, inTimestamp: AudioTimeStamp, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: AudioBufferList) -> OSStatus {
//        let output: AudioOutput = (inRedCon as? AudioOutput)!
        
//        EZOutput *output = (__bridge EZOutput *)inRefCon;
        
        //
        // Try to ask the data source for audio data to fill out the output's
        // buffer list
        //
//        if ([output.dataSource respondsToSelector:@selector(output:shouldFillAudioBufferList:withNumberOfFrames:timestamp:)])
//        {
//            return [output.dataSource output:output
//                shouldFillAudioBufferList:ioData
//                withNumberOfFrames:inNumberFrames
//                timestamp:inTimeStamp];
//        }
//        else
//        {
//            //
//            // Silence if there is nothing to output
//            //
//            for (int i = 0; i < ioData->mNumberBuffers; i++)
//            {
//                memset(ioData->mBuffers[i].mData,
//                    0,
//                    ioData->mBuffers[i].mDataByteSize);
//            }
//        }
//        return noErr
//    }
    
//    func OutputGraphRenderCallback(inRedCon: Void, ioActionFlags: AudioUnitRenderActionFlags, inTimestamp: AudioTimeStamp, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: AudioBufferList) -> OSStatus {
//    return noErr
//    }
    
    func defaultClientFormat() -> AudioStreamBasicDescription {
        var asbd: AudioStreamBasicDescription = AudioStreamBasicDescription()
        let floatByteSize  = UInt32(sizeof(Float));
        asbd.mBitsPerChannel   = 8 * floatByteSize;
        asbd.mBytesPerFrame    = floatByteSize;
        asbd.mChannelsPerFrame = 2;
        asbd.mFormatFlags      = kAudioFormatFlagIsFloat|kAudioFormatFlagIsNonInterleaved;
        asbd.mFormatID         = kAudioFormatLinearPCM;
        asbd.mFramesPerPacket  = 1;
        asbd.mBytesPerPacket   = asbd.mFramesPerPacket * asbd.mBytesPerFrame;
        asbd.mSampleRate       = OutputDefaultSampleRate;
        return asbd;
    }
    
    func defaultInputFormark() -> AudioStreamBasicDescription {
        var asbd: AudioStreamBasicDescription = AudioStreamBasicDescription()
        let floatByteSize  = UInt32(sizeof(Float));
        asbd.mChannelsPerFrame = 2;
        asbd.mBitsPerChannel   = 8 * floatByteSize;
        asbd.mBytesPerFrame    = asbd.mChannelsPerFrame * floatByteSize;
        asbd.mFramesPerPacket  = 1;
        asbd.mBytesPerPacket   = asbd.mFramesPerPacket * asbd.mBytesPerFrame;
        asbd.mFormatFlags      = kAudioFormatFlagIsFloat;
        asbd.mFormatID         = kAudioFormatLinearPCM;
        asbd.mSampleRate       = OutputDefaultSampleRate;
        asbd.mReserved         = 0;
        return asbd;
    }
}

protocol AudioOutputDataSource {
    func output(output: AudioOutput, shouldFillAudioBufferList audioBufferList: UnsafePointer<AudioBufferList>, withNumerOfFrames frames: UInt32, timestamp tms: UnsafePointer<AudioTimeStamp>) -> OSStatus
    
}

protocol AudioOutputDelegate {
    func output(output: AudioOutput, playedAudio buffer: Float, withBufferSize size: UInt32, numberOfChannels chanels: UInt32)
}
