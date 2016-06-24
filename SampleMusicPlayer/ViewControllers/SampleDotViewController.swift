//
//  SampleDotViewController.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/17/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import OpenGLES
import GLKit
import AudioToolbox
import AVFoundation

class SampleDotViewController: GLKViewController {
    
    var blocks: [BlockObject] = []
    var resource: [String] = []
    var indexPlay: Int = 0
    var ezAudioFile: EZAudioFile!
    var ezAudioPlayer: EZAudioPlayer!
    
    private let topLevel: CGFloat = 0.7
    private let reachedLevel: Float = 0.05
    private var cusPlotView: CustomPlotView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up context
        let context = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(context)
        let currentView = view as! GLKView
        currentView.context = context

        setupView()
        cusPlotView = CustomPlotView()
    }
    
    func setupView() {
        let url2 = NSBundle.mainBundle().pathForResource("winamp", ofType: "wav")
        let url3 = NSBundle.mainBundle().pathForResource("Fill", ofType: "wav")
        let url4 = NSBundle.mainBundle().pathForResource("Basic_Beat", ofType: "wav")
    
        if let _ = url2 {
            resource.append(url2!)
        }
        if let _ = url3 {
            resource.append(url3!)
        }
        if let _ = url4 {
            resource.append(url4!)
        }
        
        let session = AVAudioSession()
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        try! session.setActive(true)
        
        try! session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        
        ezAudioPlayer = EZAudioPlayer(delegate: self)
        ezAudioPlayer.shouldLoop = false
        indexPlay = 0 //initialize
        ezAudioFile = EZAudioFile(URL: NSURL(fileURLWithPath: resource[indexPlay]))
        guard let file = ezAudioFile else {
            return
        }
        
        
        ezAudioPlayer.audioFile = file
        ezAudioPlayer.play()
    }
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        // Set the background color
        glClearColor(0.1, 0.1, 0.1, 1.00)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // Set the blending function (normal w/ premultiplied alpha)
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        
        // Create Projection Matrix
        let aspectRatio = view.frame.size.width / view.frame.size.height
        let projectionMatrix = GLKMatrix4MakeScale(1.0, aspectRatio.f, 1.0)
        
        view.drawableColorFormat = .RGBA8888
        view.drawableDepthFormat = .Format24
        view.drawableStencilFormat = .Format8
        view.drawableMultisample = .Multisample4X
        view.opaque = false
        
        
        // Render Emitters
        if blocks.count > 0 {
            for bl in blocks {
                bl.renderBar(projectionMatrix)
                bl.renderWithProjection(projectionMatrix)
            }
        }
        
//        cusPlotView.redraw()
    }
    
    func update() {
        if blocks.count > 0 {
            for bl in blocks {
                bl.updateLifeCycle(Float(timeSinceLastUpdate))
                glClearColor(0.3, 0.3, 0.3, 1.0)
            }
        }
    }
    
    
    func setSampleData(data: UnsafeMutablePointer<Float>, length: Int) {
        for i in 0.stride(to: length, by: 40) {
            var yValue: Float = data[i]
            if yValue < 0 {
                yValue *= -1
            }
            
            
            if yValue > reachedLevel {
                if blocks.count == 0 {
                    addBlock(CGPointMake(CGFloat(i), yValue.g + 0.2))
                } else {
                    var shouldAdd = true
                    for bl in blocks {
                        if bl.pointStoredX == Float(i) {
                            if bl.pointStoredY  > yValue {
                                bl.isDown = false
                                
                                //Only update position if bar is moiving up
                                bl.positionStored = GLKVector2Make(bl.positionStored.x, yValue + 0.2)
                            } else {
                                bl.isDown = true
                            }
                            shouldAdd = false
                            break
                        }
                    }
                    if shouldAdd {
                        addBlock(CGPointMake(CGFloat(i), yValue.g + 0.2))
                    }
                }
            }   
        }
    }
        
    private func addBlock(point: CGPoint) {
        let glPoint = CGPointMake(point.x/view.frame.size.width, point.y/view.frame.size.height);
        let x = (glPoint.x * 2.0) - 1.0
        let block = BlockObject(texture: "block_64.png", position: GLKVector2Make(x.f, point.y.f))
        block.pointStoredX = point.x.f
        block.pointStoredY = point.y.f
        blocks.append(block)
    }
}

extension SampleDotViewController: EZAudioPlayerDelegate {
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.setSampleData(buffer[0], length: Int(bufferSize))
//            self.cusPlotView.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, reachedEndOfAudioFile audioFile: EZAudioFile!) {
        //Start to new one
        ezAudioFile = nil
        indexPlay += 1
        if indexPlay > 2 {
            indexPlay = 0;
        }
        ezAudioFile = EZAudioFile(URL: NSURL(fileURLWithPath: resource[indexPlay]))
        guard let file = ezAudioFile else {
            return
        }
        
        ezAudioPlayer.audioFile = file
        ezAudioPlayer.play()
    }
}
