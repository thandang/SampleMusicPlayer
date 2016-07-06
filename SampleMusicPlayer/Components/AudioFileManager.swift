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
    var audioFileID: AudioFileID
    var clientFormant: AudioStreamBasicDescription?
    var duration: NSTimeInterval?
    var extAudioFileRef: ExtAudioFileRef
    var fileFortmat: AudioStreamBasicDescription?
    var frames: Int64?
    var sourceURL: CFURLRef?
    init() {
        audioFileID = nil
        extAudioFileRef = nil
        frames = Int64()
    }
}

class AudioFileManager: NSObject {
    var lock: UnsafeMutablePointer<pthread_mutex_t>?
    var info: AudioFileInfo?
    var floatConverter: AudioFloatConverter?
    var floatData: UnsafeMutablePointer<UnsafeMutablePointer<Float>>?
    
    private var localUrl: NSURL?
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
                floatData = Utils.floatBufferWithNumberOfFrames(1024, channels: clientFormat!.mChannelsPerFrame)
            }
        }
    }
    
    deinit {
        if let _ = lock {
            pthread_mutex_destroy(lock!)
        }
    }
    
    override init() {
        super.init()
        info = AudioFileInfo()
        info?.fileFortmat = Utils.defaultClientFormat()
        pthread_mutex_init(lock!, nil)
    }
    
    init(url: NSURL?) {
        super.init()
        info = AudioFileInfo()
        info?.fileFortmat = Utils.defaultClientFormat()
        info?.sourceURL = url
        localUrl = url
        lock = UnsafeMutablePointer<pthread_mutex_t>.alloc(0)
        pthread_mutex_init(lock!, nil)
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
        let fileExist = NSFileManager.defaultManager().fileExistsAtPath((localUrl?.path)!)
        var extFileRef = info?.extAudioFileRef
        if fileExist {
            guard let ref = urlRef else {
                return
            }
            if extFileRef != nil {
                ExtAudioFileOpenURL(ref, &extFileRef!)
            }
            
        }
        
        //
        // Get the underlying AudioFileID
        //
        
        var propSize = UnsafeMutablePointer<UInt32>.alloc(sizeof(AudioFileID))
        var audioFileId = info?.audioFileID
        
        guard let ext = extFileRef else {
            return
        }
        ExtAudioFileGetProperty(ext, kExtAudioFileProperty_AudioFile, propSize, &audioFileId)
        
        var fileFormat = info?.fileFortmat
        propSize = UnsafeMutablePointer<UInt32>.alloc(sizeof(AudioStreamBasicDescription))
        ExtAudioFileGetProperty(ext, kExtAudioFileProperty_FileDataFormat, propSize, &fileFormat!)
        
        
        var infoFrame = info?.frames
        propSize = UnsafeMutablePointer<UInt32>.alloc(sizeof(Int64))
        ExtAudioFileGetProperty(ext, kExtAudioFileProperty_FileLengthFrames, propSize, &infoFrame)
        
        let sampleRate = info?.fileFortmat!.mSampleRate
        let interval = (info?.frames)! / Int64(sampleRate!)
        info?.duration = NSTimeInterval(interval)
    }
    
    
    func readFrame(frames: UInt32, audoBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, bufferSize size: UnsafeMutablePointer<UInt32>, eof: UnsafeMutablePointer<Bool>) {
        if (pthread_mutex_trylock(lock!) == 0) {
            var targetFrame = frames
            ExtAudioFileRead((info?.extAudioFileRef)!, &targetFrame, bufferList)
            if  let del  = delegate {
                floatConverter?.convertDataFromAudioBufferList(bufferList, frames: targetFrame, buffers: floatData!)
                let channels = clientFormat!.mChannelsPerFrame
                del.audioFile(self, buffer: floatData!, bufferSize: targetFrame, numberChanels: channels)
            }
        }
        pthread_mutex_unlock(lock!);
    }
}

protocol AudioFileDelegate {
    func audioFile(file: AudioFileManager, buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, bufferSize: UInt32, numberChanels: UInt32)
}

