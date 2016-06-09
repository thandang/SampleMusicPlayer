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
    // stream format params
    var inputFormat: AudioStreamBasicDescription?
    var clientFormat: AudioStreamBasicDescription?
    
    var floatData: [Float]?
    
    var converterNodeInfo: AudioNodeInfo?
    var mixerNodeInfo: AudioNodeInfo?
    var outputNodeInfo: AudioNodeInfo?
    var graph: AUGraph?
}

//MARK - Callback
typealias OutputGraphRenderCallback = (inRedCon: UnsafeMutablePointer<Void>, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimestamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus


typealias OutputConverterInputCallback = (inRedCon: UnsafeMutablePointer<Void>, ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimestamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus

class AudioOutput: NSObject {
    
    private var info: AudioOutputInfo?
    var datasource: AudioOutputDataSource?
    var delegate: AudioOutputDelegate?
    var floatConverter: AudioFloatConverter?
    
    let OutputMaximumFramesPerSlide: UInt32 = 4096
    
    var grapRenderCallback: OutputGraphRenderCallback = { red, actionFlags, timestamp, busNumber, numberFrames, ioData in
        
        return noErr
    }
    
    var converterInputCallback: OutputConverterInputCallback = { red, actionFlags, timestamp, busNumber, numberFrames, ioData in
        //Do something here
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
        
        var converterCallback: AURenderCallbackStruct = AURenderCallbackStruct(inputProc: { (context, actionFlags, timestamp, bus, frames, data) -> OSStatus in
           let output: AudioOutput = Utils.bridgeBack(context)
            
            //
            // Try to ask the data source for audio data to fill out the output's
            // buffer list
            //
            let bufferList: AudioBufferList = unsafeBitCast(data, AudioBufferList.self)
            if let _ = output.datasource {
                let frames: UInt32 = bufferList.mBuffers.mDataByteSize / (output.info?.clientFormat!.mBytesPerFrame)!
                let targetTimestamp = unsafeBitCast(timestamp, AudioTimeStamp.self)
                return output.datasource!.output(output, shouldFillAudioBufferList: bufferList,
                    withNumerOfFrames: frames, timestamp: targetTimestamp)
            } else {
                memset(bufferList.mBuffers.mData, 0, Int(bufferList.mBuffers.mDataByteSize))
            }

            return noErr
            }, inputProcRefCon: Utils.bridge(self))
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
        
        AudioUnitAddRenderNotify((mixerInfo!.audioUnit)!, { (context, actionFlags, timestamp, bus, frames, data) -> OSStatus in
            
            let output: AudioOutput = Utils.bridgeBack(context)
            
            if let _ = output.delegate {
                let bufferList: AudioBufferList = unsafeBitCast(data, AudioBufferList.self)
                let frames: UInt32 = bufferList.mBuffers.mDataByteSize / (output.info?.clientFormat!.mBytesPerFrame)!
                output.floatConverter?.convertDataFromAudioBufferList(bufferList, frames: frames, buffers: output.info!.floatData!)
                output.delegate?.output(output, playedAudio: (output.info?.floatData)!, withBufferSize: frames, numberOfChannels: (output.info!.clientFormat?.mChannelsPerFrame)!)
            }
          
            return noErr
            }, Utils.bridge(self))
    }
    
    func setClientFormat(clientFormat: AudioStreamBasicDescription) {
        if let _ = floatConverter {
            floatConverter = nil
            //Free float buffer
            //        if (self.floatConverter)
            //        {
            //            self.floatConverter = nil;
            //            [EZAudioUtilities freeFloatBuffers:self.info->floatData
            //                numberOfChannels:self.clientFormat.mChannelsPerFrame];
            //        }
        }
        
        guard let targetInfo = info else {
            return
        }
        var targetClient = targetInfo.clientFormat
        info?.clientFormat = clientFormat
        AudioUnitSetProperty((info?.converterNodeInfo!.audioUnit)!,
                             kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Output, 0, &targetClient,
                             UInt32(sizeof(AudioStreamBasicDescription)))
        
        
        AudioUnitSetProperty((info?.mixerNodeInfo!.audioUnit)!, kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Input, 0, &targetClient, UInt32(sizeof(AudioStreamBasicDescription)))
        
        
        floatConverter = AudioFloatConverter(inputFormat_: clientFormat)
//        
//        self.floatConverter = [[EZAudioFloatConverter alloc] initWithInputFormat:clientFormat];
//        self.info->floatData = [EZAudioUtilities floatBuffersWithNumberOfFrames:EZOutputMaximumFramesPerSlice
//        numberOfChannels:clientFormat.mChannelsPerFrame];
    }
    
    func startPlayback() {
        AUGraphStart((info?.graph)!)
    }
    
    func stopPlayback() {
        AUGraphStop((info?.graph)!)
    }
    
    
    func connectOUtputOfSourceNode(sourceNode: AUNode, sourceNodeOutputBus: UInt32, destinateNode: AUNode, destinateNodeBus: UInt32, inGraph: AUGraph) -> OSStatus {
        return -1
    }
}

protocol AudioOutputDataSource {
    func output(output: AudioOutput, shouldFillAudioBufferList audioBufferList: AudioBufferList, withNumerOfFrames frames: UInt32, timestamp tms: AudioTimeStamp) -> OSStatus
    
}

protocol AudioOutputDelegate {
    func output(output: AudioOutput, playedAudio buffer: [Float], withBufferSize size: UInt32, numberOfChannels chanels: UInt32)
}
