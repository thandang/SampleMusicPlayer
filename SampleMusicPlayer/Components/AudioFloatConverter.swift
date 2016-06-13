//
//  AudioFloatConverter.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/9/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import AudioToolbox
import CoreAudioKit

struct AudioFloatConverterInfo {
    var converterRef: AudioConverterRef?
    var floatAudioBufferList: UnsafeMutablePointer<AudioBufferList>?
    var inputFormat: AudioStreamBasicDescription?
    var outputFormat: AudioStreamBasicDescription?
    var packetDescription: AudioStreamPacketDescription?
    var packetPerBuffer: UInt32?
    init() {
        packetDescription = AudioStreamPacketDescription()
    }
}

class AudioFloatConverter: NSObject {
    var info: AudioFloatConverterInfo!
    override init() {
        super.init()
        
    }
    init(inputFormat_: AudioStreamBasicDescription) {
        super.init()
        info = AudioFloatConverterInfo()
        memset(&info, 0, sizeof(AudioFloatConverterInfo));
        info.inputFormat = inputFormat_
        setup()
    }
    
    deinit {
        AudioConverterDispose(info.converterRef!);
        free(&info.packetDescription)
        free(&info)
    }
    
    func setup() {
       info.outputFormat = Utils.defaultInputFormark()
        
        // create output format
        
        info.outputFormat = Utils.floatFormatWithNumberOfChannels(info.inputFormat!.mChannelsPerFrame, sampleRate: info.inputFormat!.mSampleRate)
        
        AudioConverterNew(&info.inputFormat!, &info.outputFormat!, &info.converterRef!)
        
        var packetsPerBuffer: UInt32 = 0
        var outputBufferSize: UInt32 = 128 * 32;
        let sizePerPacket: UInt32 = info.inputFormat!.mBytesPerPacket
        let isVBR = sizePerPacket == 0
        if isVBR {
            var maxOutputPacketSize:UInt32 = 0
            var propSize: UInt32 = 0
            let status: OSStatus = AudioConverterGetProperty(info.converterRef!, kAudioConverterPropertyMaximumOutputPacketSize, &propSize, &maxOutputPacketSize)
            if status != noErr {
                maxOutputPacketSize = 2048
            }
            if maxOutputPacketSize > outputBufferSize {
                outputBufferSize = maxOutputPacketSize
            }
            packetsPerBuffer = outputBufferSize / maxOutputPacketSize
        } else {
            packetsPerBuffer = outputBufferSize / sizePerPacket;
        }
      
        info.packetPerBuffer = packetsPerBuffer
        info.floatAudioBufferList = Utils.audioBufferListWithNumerOfFrames(packetsPerBuffer, channels: info.outputFormat!.mChannelsPerFrame)
    }
    
    func convertDataFromAudioBufferList(audioBufferList: UnsafeMutablePointer<AudioBufferList>, frames: UInt32, buffers: UnsafeMutablePointer<UnsafeMutablePointer<Float>>) {
        if (frames != 0) {
            //
            // Make sure the data size coming in is consistent with the number
            // of frames we're actually getting
            //
            var copyFrames = frames
            audioBufferList[0].mBuffers.mDataByteSize = frames * (info?.inputFormat?.mBytesPerFrame)!
            AudioConverterFillComplexBuffer(info.converterRef!, { (convertRef, NumberDataPackets, bufferListData, streamDescriptionList, userData) -> OSStatus in
                
                    return noErr
                }, audioBufferList, &copyFrames, &info.floatAudioBufferList![0], &info.packetDescription!)
            AudioConverterFillComplexBuffer(info.converterRef!, { (convertRef, numberDataPackets, data, userData, outDataPacketDescription) -> OSStatus in
                
                var sourceBuffer = unsafeBitCast(userData, AudioBufferList.self)
                
                var copyData = data
                let convertNum = Int(sourceBuffer.mNumberBuffers - 1)
                
                memcpy(&copyData, &sourceBuffer, sizeof(AudioBufferList) + convertNum * sizeof(AudioBuffer))
                free(&sourceBuffer)
                
                return noErr
                }, audioBufferList, &copyFrames, &info.floatAudioBufferList![0], &info.packetDescription!)

            
            let numBuffers = info?.floatAudioBufferList![0].mNumberBuffers
            for i in 0...Int(numBuffers!) {
                memcpy(&buffers[i], info.floatAudioBufferList![i].mBuffers.mData, Int(info.floatAudioBufferList![i].mBuffers.mDataByteSize))
            }
//            memcpy(&buffers[0], info.floatAudioBufferList![0].mBuffers.mData, Int(info.floatAudioBufferList![0].mBuffers.mDataByteSize))
        }
    }
}
