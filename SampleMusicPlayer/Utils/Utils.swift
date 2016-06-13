//
//  Utils.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/6/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import AudioToolbox
import CoreAudioKit
import AVFoundation

let OutputDefaultSampleRate: Float64 = 44100.0



public class Utils {
    static func audioBufferListWithNumerOfFrames (frames: UInt32, channels: UInt32) -> UnsafeMutablePointer<AudioBufferList> {
        let lastItem = channels - 1
        let audioBufferList = UnsafeMutablePointer<AudioBufferList>.alloc(sizeof(AudioBufferList) + sizeof(AudioBuffer) * Int(lastItem))
        
        let bufferSize = sizeof(Float) * Int(frames)
        var audioBuffer = AudioBuffer()
        audioBuffer.mData = calloc(bufferSize, 1)
        audioBuffer.mNumberChannels = 1
        audioBuffer.mDataByteSize = UInt32(bufferSize)
        var targetBufferList = AudioBufferList(mNumberBuffers: channels, mBuffers: audioBuffer)
        audioBufferList.assignFrom(&targetBufferList, count: 1)
        return audioBufferList
    }
    
    static func defaultClientFormat() -> AudioStreamBasicDescription {
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
    
    static func defaultInputFormark() -> AudioStreamBasicDescription {
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
    
    static func floatFormatWithNumberOfChannels(channels: UInt32, sampleRate: Float64) -> AudioStreamBasicDescription {
        var asbd: AudioStreamBasicDescription = AudioStreamBasicDescription()
        let floatByteSize  = UInt32(sizeof(Float))
        asbd.mChannelsPerFrame = 2;
        asbd.mBitsPerChannel   = 8 * floatByteSize
        asbd.mBytesPerFrame    = floatByteSize
        asbd.mBytesPerPacket   = floatByteSize
        asbd.mFramesPerPacket  = 1;
        asbd.mChannelsPerFrame = channels
        asbd.mBytesPerPacket   = asbd.mFramesPerPacket * asbd.mBytesPerFrame
        asbd.mFormatFlags      = kAudioFormatFlagIsFloat|kAudioFormatFlagIsNonInterleaved
        asbd.mFormatID         = kAudioFormatLinearPCM;
        asbd.mSampleRate       = sampleRate
        asbd.mReserved         = 0;
        return asbd;
    }
    
    static func floatBufferWithNumberOfFrames(frames: UInt32, channels: UInt32) -> UnsafeMutablePointer<UnsafeMutablePointer<Float>> {
        var size = sizeof(Float) * Int(channels);
        let buffers:UnsafeMutablePointer<UnsafeMutablePointer<Float>> = UnsafeMutablePointer<UnsafeMutablePointer<Float>>.alloc(size)
        for i in 0...Int(channels) {
            size = sizeof(Float) * Int(frames)
            buffers[i] = UnsafeMutablePointer<Float>.alloc(size)
        }
        return buffers;
    }
    
    
    static func bridge<T : AnyObject>(obj : T) -> UnsafeMutablePointer<Void> {
        return UnsafeMutablePointer(Unmanaged.passUnretained(obj).toOpaque())
        // return unsafeAddressOf(obj) // ***
    }
    
    static func bridgeBack<T : AnyObject>(ptr : UnsafeMutablePointer<Void>) -> T {
        return Unmanaged<T>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
        // return unsafeBitCast(ptr, T.self) // ***
    }
    
    static func bridgeUnMutable<T : AnyObject>(obj : T) -> UnsafePointer<Void> {
        return UnsafePointer(Unmanaged.passUnretained(obj).toOpaque())
    }
    
    static func bridgeBackUnMutable<T: AnyObject>(ptr: UnsafePointer<Void>) -> T {
        return Unmanaged<T>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
    }
}
