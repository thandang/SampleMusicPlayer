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
    init() {
        audioUnit = nil
        node = AUNode()
    }
}

struct AudioOutputInfo {
    // stream format params
    var inputFormat: AudioStreamBasicDescription?
    var clientFormat: AudioStreamBasicDescription?
    
    var floatData: UnsafeMutablePointer<UnsafeMutablePointer<Float>>?
    
    var converterNodeInfo: AudioNodeInfo
    var mixerNodeInfo: AudioNodeInfo
    var outputNodeInfo: AudioNodeInfo
    var graph: AUGraph
    init() {
        graph = AUGraph()
        converterNodeInfo = AudioNodeInfo()
        mixerNodeInfo = AudioNodeInfo()
        outputNodeInfo = AudioNodeInfo()
    }
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
//        info = AudioOutputInfo()
        info = UnsafeMutablePointer<AudioOutputInfo>.alloc(sizeof(AudioOutputInfo))[0]
        memset(&info, 0, sizeof(AudioOutputInfo))
        var graph_ = info?.graph
        
        NewAUGraph(&graph_!)
        info?.graph  = graph_!
        
        
        var converterDescription: AudioComponentDescription = AudioComponentDescription()
        
        converterDescription.componentType = kAudioUnitType_FormatConverter;
        converterDescription.componentSubType = kAudioUnitSubType_AUConverter;
        converterDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        var convertInfo = info?.converterNodeInfo
        AUGraphAddNode((info?.graph)!, &converterDescription, &convertInfo!.node)
        
        //
        // Add mixer node
        //
        var mixerDescription: AudioComponentDescription = AudioComponentDescription()
        mixerDescription.componentType = kAudioUnitType_Mixer;
        mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
        
        mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        var mixerInfo = info?.mixerNodeInfo
        AUGraphAddNode((info?.graph)!, &mixerDescription, &mixerInfo!.node)
        
        //
        // Add output node
        //
        var outputDescription: AudioComponentDescription = AudioComponentDescription()
        outputDescription.componentType = kAudioUnitType_Output
        outputDescription.componentSubType = kAudioUnitSubType_RemoteIO
        outputDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        var outputInfo = info?.outputNodeInfo
        AUGraphAddNode((info?.graph)!, &outputDescription, &outputInfo!.node)
        
        //
        // Open the graph
        //
        AUGraphOpen((info?.graph)!)
        
        //
        // Make node connections
        //
        
        connectOUtputOfSourceNode(convertInfo!.node, sourceNodeOutputBus: 0,
                                  destinateNode: mixerInfo!.node,
                                  destinateNodeBus: 0, inGraph: graph_!)
        
        //
        // Connect mixer to output
        //
        AUGraphConnectNodeInput(graph_!, mixerInfo!.node, 0, outputInfo!.node, 0)
        
        //
        // Get the audio units
        //
        
        AUGraphNodeInfo((info?.graph)!, convertInfo!.node, &converterDescription, &convertInfo!.audioUnit)
    
        AUGraphNodeInfo((info?.graph)!, mixerInfo!.node, &mixerDescription, &mixerInfo!.audioUnit)
        
        AUGraphNodeInfo((info?.graph)!, outputInfo!.node, &outputDescription, &outputInfo!.audioUnit)
        
        
        //
        // Add a node input callback for the converter node
        //
        
        var converterCallback: AURenderCallbackStruct = AURenderCallbackStruct(inputProc: { (context, actionFlags, timestamp, bus, frames, data) -> OSStatus in
           let output: AudioOutput = Utils.bridgeBack(context)
            
            // Try to ask the data source for audio data to fill out the output's
            if let _ = output.datasource {
                let frames_ = data[0].mBuffers.mDataByteSize / (output.info?.clientFormat!.mBytesPerFrame)!
                return output.datasource!.output(output, shouldFillAudioBufferList: data,
                    withNumerOfFrames: frames_, timestamp: timestamp)
            } else {
                memset(data[0].mBuffers.mData, 0, Int(data[0].mBuffers.mDataByteSize))
            }

            return noErr
            }, inputProcRefCon: Utils.bridge(self))
        AUGraphSetNodeInputCallback((info?.graph)!, convertInfo!.node, 0, &converterCallback)

        //
        // Set stream formats
        //
        setClientFormat(Utils.defaultClientFormat())
        setInputFormat(Utils.defaultInputFormark())
        
        
        //
        // Set maximum frames per slice to 4096 to allow playback during
        // lock screen (iOS only?)
        //
        var maximumFramesPerSlice = OutputMaximumFramesPerSlide
        AudioUnitSetProperty(mixerInfo!.audioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maximumFramesPerSlice, maximumFramesPerSlice)
        
        
        //
        // Initialize all the audio units in the graph
        //
        AUGraphInitialize((info?.graph)!)
        
        
        // Add render callback
        AudioUnitAddRenderNotify(mixerInfo!.audioUnit, { (context, actionFlags, timestamp, numBus, numFrames, data) -> OSStatus in
            
            let output: AudioOutput = Utils.bridgeBack(context)
            
            if let _ = output.delegate {
                let frames = data[0].mBuffers.mDataByteSize / (output.info?.clientFormat?.mBytesPerFrame)!
                output.floatConverter?.convertDataFromAudioBufferList(data, frames: frames, buffers: output.info!.floatData!)
                output.delegate?.output(output, playedAudio: (output.info!.floatData)!,
                    withBufferSize: numFrames,
                    numberOfChannels: (output.info!.clientFormat?.mChannelsPerFrame)!)
            }
          
            return noErr
            }, Utils.bridge(self))
    }
    
    func setClientFormat(clientFormat: AudioStreamBasicDescription) {
        if let _ = floatConverter {
            floatConverter = nil
            for i in 0...Int((info?.clientFormat?.mChannelsPerFrame)!) {
                free((info?.floatData![i])!)
            }
            free((info?.floatData)!)
        }
        
        guard let targetInfo = info else {
            return
        }
        var targetClient = targetInfo.clientFormat
        info?.clientFormat = clientFormat
        AudioUnitSetProperty((info?.converterNodeInfo.audioUnit)!,
                             kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Output, 0, &targetClient,
                             UInt32(sizeof(AudioStreamBasicDescription)))
        
        
        AudioUnitSetProperty((info?.mixerNodeInfo.audioUnit)!, kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Input, 0, &targetClient, UInt32(sizeof(AudioStreamBasicDescription)))
        
        
        floatConverter = AudioFloatConverter(inputFormat_: clientFormat)
        info?.floatData = Utils.floatBufferWithNumberOfFrames(OutputMaximumFramesPerSlide, channels: clientFormat.mChannelsPerFrame)
    }
    
    func setInputFormat(inputFormat: AudioStreamBasicDescription) {
        info?.inputFormat = inputFormat
        var copyInputFormat = inputFormat
        AudioUnitSetProperty((info?.converterNodeInfo.audioUnit)!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &copyInputFormat, UInt32(sizeof(AudioStreamBasicDescription)))
    }
    
    func startPlayback() {
        AUGraphStart((info?.graph)!)
    }
    
    func stopPlayback() {
        AUGraphStop((info?.graph)!)
    }
    
    
    func connectOUtputOfSourceNode(sourceNode: AUNode, sourceNodeOutputBus: UInt32, destinateNode: AUNode, destinateNodeBus: UInt32, inGraph: AUGraph) -> OSStatus {
        AUGraphConnectNodeInput(inGraph, sourceNode, sourceNodeOutputBus, destinateNode, destinateNodeBus)
        return noErr
    }
}

protocol AudioOutputDataSource {
    func output(output: AudioOutput, shouldFillAudioBufferList audioBufferList: UnsafeMutablePointer<AudioBufferList>, withNumerOfFrames frames: UInt32, timestamp tms: UnsafePointer<AudioTimeStamp>) -> OSStatus
    
}

protocol AudioOutputDelegate {
    func output(output: AudioOutput, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize size: UInt32, numberOfChannels chanels: UInt32)
}
