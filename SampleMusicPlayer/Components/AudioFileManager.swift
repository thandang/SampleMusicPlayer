//
//  AudioFileManager.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/7/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import AudioToolbox


struct AudioFileInfo {
    var audioFileID: AudioFileID?
    var clientFormant: AudioStreamBasicDescription?
    var duration: NSTimeInterval?
    var extAudioFileRef: ExtAudioFileRef?
    var fileFortmat: AudioStreamBasicDescription?
    var frames: Int64?
    var sourceURL: CFURLRef?
}

class AudioFileManager: NSObject {
    var lock: pthread_mutex_t?
    var info: AudioFileInfo?
    var floatConverter: AudioFloatConverter?
    var floatData: [Float]?
    
    var url: String?
    var delegate: AudioFileDelegate?
    var clientFormat: AudioStreamBasicDescription? {
        didSet {
            //
            // Clear any float data currently cached
            //
            if let _ = floatData {
                floatData = nil
            }
            if let _ = clientFormat {
                clientFormat!.mFormatID = kAudioFormatLinearPCM;
                
                info?.clientFormant = clientFormat!
                var copyClientFormat = clientFormat
                ExtAudioFileSetProperty((info?.extAudioFileRef)!, kExtAudioFileProperty_ClientDataFormat,  UInt32(sizeof(AudioStreamBasicDescription)),  &copyClientFormat)
                
                
                //
                // Create a new float converter using the client format as the input format
                //
                floatConverter = AudioFloatConverter(inputFormat_: clientFormat!)
                
                //
                // Determine how big our float buffers need to be to hold a buffer of float
                // data for the audio received callback.
                //
                
                var maxOutputPacketSize:UInt32 = 0
                var propSize: UInt32 = 0
                let status: OSStatus = ExtAudioFileGetProperty((info?.extAudioFileRef)!, kExtAudioFileProperty_ClientMaxPacketSize, &propSize, &maxOutputPacketSize)
                if status != noErr {
                    maxOutputPacketSize = 2048
                }
//                floatData = Utils.floatBufferWithNumberOfFrames(1024, channels: clientFormat!.mChannelsPerFrame)
            }
        }
    }
    
    deinit {
        if let _ = lock {
            pthread_mutex_destroy(&lock!)
        }
    }
    
    override init() {
        super.init()
        info = AudioFileInfo()
        info?.fileFortmat = Utils.defaultClientFormat()
        pthread_mutex_init(&lock!, nil)
    }
    
    init(url: NSURL?) {
        super.init()
        setup()
    }
    
    init(url: NSURL, delegate_: AudioFileDelegate?) {
        super.init()
        delegate = delegate_
        info?.sourceURL = url
        
        setup()
    }
    
    func setup() {
        let urlRef = info?.sourceURL
        let url = urlRef as? NSURL
        let fileExist = NSFileManager.defaultManager().fileExistsAtPath((url?.path)!)
        var extFileRef = info?.extAudioFileRef
        if fileExist {
            ExtAudioFileOpenURL(url!, &extFileRef!)
        }
        
        //
        // Get the underlying AudioFileID
        //
        
        let propSize: UInt32 = 0
        var audioFileId = info?.audioFileID
        ExtAudioFileSetProperty((info?.extAudioFileRef)!, kExtAudioFileProperty_AudioFile, propSize, &audioFileId!)
        
        var fileFormat = info?.fileFortmat
        ExtAudioFileSetProperty((info?.extAudioFileRef)!, kExtAudioFileProperty_FileDataFormat, propSize, &fileFormat!)
        
        let newProp = sizeof(Int64)
        var infoFrame = info?.frames
        ExtAudioFileSetProperty((info?.extAudioFileRef)!, kExtAudioFileProperty_FileLengthFrames, UInt32(newProp), &infoFrame!)
        
        let sampleRate = info?.fileFortmat!.mSampleRate
        let interval = (info?.frames)! / Int64(sampleRate!)
        info?.duration = NSTimeInterval(interval)
    }
    
    
    func readFrame(frames: UInt32, audoBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, bufferSize size: UnsafeMutablePointer<UInt32>, eof: UnsafeMutablePointer<Bool>) {
        if (pthread_mutex_trylock(&lock!) == 0) {
            ExtAudioFileRead((info?.extAudioFileRef)!, unsafeBitCast(frames, UnsafeMutablePointer<UInt32>.self), bufferList)
            if  let del  = delegate {
                floatConverter?.convertDataFromAudioBufferList(bufferList, frames: frames, buffers: floatData!)
                let channels = clientFormat!.mChannelsPerFrame
                del.audioFile(self, buffer: floatData!, bufferSize: unsafeBitCast(size, UInt32.self), numberChanels: channels)
            }
        }
        pthread_mutex_unlock(&lock!);
    }
}

protocol AudioFileDelegate {
    func audioFile(file: AudioFileManager, buffer: [Float], bufferSize: UInt32, numberChanels: UInt32)
//    func audioFile(file: AudioFileManager, buffer: AutoreleasingUnsafeMutablePointer<Float>, bufferSize: UInt32, numberChanels: UInt32)
}

