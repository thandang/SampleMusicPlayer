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
    
    class func checkError(tag:String) {
        let error = glGetError()
        
        switch Int32(error) {
        case GL_INVALID_VALUE:
            NSLog("OpenGLES Error: tag: %@: GL_INVALID_VALUE", tag)
        case GL_INVALID_OPERATION:
            NSLog("OpenGLES Error: tag: %@: GL_INVALID_OPERATION", tag)
        case GL_STACK_OVERFLOW:
            NSLog("OpenGLES Error: tag: %@: GL_STACK_OVERFLOW", tag)
        case GL_STACK_UNDERFLOW:
            NSLog("OpenGLES Error: tag: %@: GL_STACK_UNDERFLOW", tag)
        case GL_OUT_OF_MEMORY:
            NSLog("OpenGLES Error: tag: %@: GL_OUT_OF_MEMORY", tag)
        default:
            return
        }
    }
    
    class func checkFrameBufferStatus(framebuffer:GLenum) {
        let status  = glCheckFramebufferStatus(framebuffer)
        
        switch Int32(status) {
        case GL_FRAMEBUFFER_UNDEFINED:
            NSLog("GL_FRAMEBUFFER_UNDEFINED")
        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
            NSLog("GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT")
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            NSLog("GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT")
        case GL_FRAMEBUFFER_UNSUPPORTED:
            NSLog("GL_FRAMEBUFFER_UNSUPPORTED")
        case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE:
            NSLog("GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE")
        default:
            return
        }
    }
    
    class func dumpRenderbufferInfo() {
        var width:GLint = 0
        var height:GLint = 0
        var format:GLint = 0
        var red:GLint = 0
        var green:GLint = 0
        var blue:GLint = 0
        var alpha:GLint = 0
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &width)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &height)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_INTERNAL_FORMAT), &format)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_RED_SIZE), &red)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_GREEN_SIZE), &green)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_BLUE_SIZE), &blue)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_ALPHA_SIZE), &alpha)
        
        Utils.checkError("glGetRenderbufferParameteriv")
        
        switch format {
        case GL_RGBA:
            NSLog("Format is GL_RGBA")
        case GL_RGBA4:
            NSLog("Format is GL_RGBA4")
        case GL_RGB5_A1:
            NSLog("Format is GL_RGB5_A1")
        case GL_RGB565:
            NSLog("Format is GL_RGB565")
        case GL_DEPTH_COMPONENT16:
            NSLog("Format is GL_DEPTH_COMPONENT16")
        case GL_STENCIL_INDEX8:
            NSLog("Format is GL_STENCIL_INDEX8")
        default:
            NSLog("Format is Unknown")
        }
    }
    
    class func ptr <T> (ptr: UnsafePointer<T>) -> UnsafePointer<T> { return ptr }
}
