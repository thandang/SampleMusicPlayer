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
    var audoFileID: AudioFileID?
    var clientFormant: AudioStreamBasicDescription
    var duration: NSTimeInterval
    var extAudioFileRef: ExtAudioFileRef
    var fileFortmat: AudioStreamBasicDescription
    var frames: Int64
    var sourceURL: CFURLRef
}

class AudioFileManager: NSObject {
    var lock: pthread_mutex_t?
    var info: AudioFileInfo?
    var queueForm: dispatch_queue_t?
    
    var url: String?
    var delegate: AudioFileDelegate?
    
    deinit {
        if let _ = lock {
            pthread_mutex_destroy(&lock!)
        }
    }
    
    override init() {
        super.init()
        pthread_mutex_init(&lock!, nil)
    }
    
    init(url: NSURL?) {
        super.init()
        
    }
    
    init(url: NSURL?, delegate_: AudioFileDelegate?) {
        super.init()
        delegate = delegate_
        
    }
    
    
    func readFrame(frames: UInt32, audoBufferList bufferList: AudioBufferList, bufferSize size: UnsafeMutablePointer<UInt32>, eof: UnsafeMutablePointer<Bool>) {
        if (pthread_mutex_trylock(&lock!) == 0)
        {
//            // perform read
//            [EZAudioUtilities checkResult:ExtAudioFileRead(self.info->extAudioFileRef,
//                &frames,
//                audioBufferList)
//                operation:"Failed to read audio data from file"];
//            *bufferSize = frames;
//            *eof = frames == 0;
//            
//            //
//            // Notify delegate
//            //
//            if ([self.delegate respondsToSelector:@selector(audioFileUpdatedPosition:)])
//            {
//                [self.delegate audioFileUpdatedPosition:self];
//            }
//            
//            //
//            // Deprecated, but supported until 1.0
//            //
//            #pragma GCC diagnostic push
//            #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
//            if ([self.delegate respondsToSelector:@selector(audioFile:updatedPosition:)])
//            {
//                [self.delegate audioFile:self updatedPosition:[self frameIndex]];
//            }
//            #pragma GCC diagnostic popx
//            
//            if ([self.delegate respondsToSelector:@selector(audioFile:readAudio:withBufferSize:withNumberOfChannels:)])
//            {
//                // convert into float data
//                [self.floatConverter convertDataFromAudioBufferList:audioBufferList
//                    withNumberOfFrames:*bufferSize
//                    toFloatBuffers:self.floatData];
//
//                // notify delegate
//                UInt32 channels = self.clientFormat.mChannelsPerFrame;
//                [self.delegate audioFile:self
//                    readAudio:self.floatData
//                    withBufferSize:*bufferSize
//                    withNumberOfChannels:channels];
            }
        
            pthread_mutex_unlock(&lock!);
//        ExtAudioFileRead((info?.extAudioFileRef)!, frames, bufferList)
    }
}

protocol AudioFileDelegate {
    func audioFile(file: AudioFileManager, buffer: [Float], bufferSize: UInt32, numberChanels: UInt32)
//    func audioFile(file: AudioFileManager, buffer: AutoreleasingUnsafeMutablePointer<Float>, bufferSize: UInt32, numberChanels: UInt32)
}

