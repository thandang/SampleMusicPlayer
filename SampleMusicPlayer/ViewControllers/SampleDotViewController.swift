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

let multipleValue: Double = 1

class SampleDotViewController: GLKViewController {
    
    var blocks: [BlockObject] = []
    var resource: [String] = []
    var indexPlay: Int = 0
    var ezAudioFile: EZAudioFile!
    var ezAudioPlayer: EZAudioPlayer!
    var inputDatas: [InputData] = []
    
    private let topLevel: CGFloat = 0.7
    private let reachedLevel: Float = 0.05
    private var cusPlotView: CustomPlotView!
    private var displayLink: AudioDisplayLink!
    
    private let timeStamp: [Float] = [2.0, 1.5, 1.0, 0.5, 0.25, 0.1]
    private var timeElapsed: Double = 0.0

    private let level0: Double = 0.1 * multipleValue
    private let level1: Double = 0.25 * multipleValue
    private let level2: Double = 0.5 * multipleValue
    private let level3: Double = 1.0 * multipleValue
    private let level4: Double = 1.5 * multipleValue
    private let level5: Double = 2.0 * multipleValue
    private let maxLevel: CGFloat = 0.2
    private let isAllowNewBlock = true
    
    private var isRunningOnce = false

    
    private var addedLevel: Int = 6 //Store added level to make sure one level added once at a time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up context
        let context = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(context)
        self.preferredFramesPerSecond = 60;
        let currentView = view as! GLKView
        currentView.context = context

        //C function involke
        setupScreen()
        on_surface_changed(Int32(view.bounds.size.width), Int32(view.bounds.size.height));
        
//        setupView()
        cusPlotView = CustomPlotView()
        displayLink = AudioDisplayLink(delegate: self)
        displayLink.start()
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
//        glClearColor(0.1, 0.1, 0.1, 1.00)
//        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
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
        
        if inputDatas.count > 0 {
            for item in inputDatas {
                renderBlockWithStepUpdate(0.1, item)
            }
        }
        
        // Render Emitters
        if blocks.count > 0 {
            for bl in blocks {
                bl.renderBar(projectionMatrix)
                bl.renderWithProjection(projectionMatrix)
            }
        }
    }
    
    func update() {
        if blocks.count > 0 {
            for bl in blocks {
                bl.updateLifeCycle(Float(timeSinceLastUpdate))
                glClearColor(0.3, 0.3, 0.3, 1.0)
            }
        }
    }

    
    private func addBlockAtIndex(index: Int) {
        if isAllowNewBlock {
            if inputDatas.count > 0 && inputDatas.count > index {
                var data = inputDatas[index]
                data.positionY = maxLevel.f
            } else {
                addNewBlock(CGPointMake(CGFloat(5 - index) * 40.0 + 20, maxLevel))
            }
        } else {
            if blocks.count > 0 && blocks.count > index {
                let block = blocks[index]
                block.isDown = false
                block.positionStored = GLKVector2Make(block.positionStored.x, maxLevel.f)
            } else {
                addBlock(CGPointMake(CGFloat(5 - index) * 40.0 + 20, maxLevel))
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
    
    private func addNewBlock(point: CGPoint) {
        let glPoint = CGPointMake(point.x/view.frame.size.width, point.y/view.frame.size.height);
        let x = (glPoint.x * 2.0) - 1.0
        let inputData = InputData(positionX: x.f, positionY: point.y.f, sizeStart: 32.0, sizeEnd: 32.0, delta: 0.1)
        inputDatas.append(inputData)
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

extension SampleDotViewController: AudioDisplayLinkDelegate {
    func displayLinkNeedDisplay(link: AudioDisplayLink) {
//        timeElapsed += link.timeSinceLastUpdate
        timeElapsed += 0.1
        if timeElapsed >= level5 {
            timeElapsed = 0
            if addedLevel != 5 {
                addedLevel = 5
                addBlockAtIndex(5)
            }
        } else if timeElapsed < level5 && timeElapsed >= level4 {
            if addedLevel != 4 {
                addedLevel = 4
                addBlockAtIndex(4)
            }
        } else if timeElapsed < level4 && timeElapsed >= level3 {
            if addedLevel != 3 {
                addedLevel = 3
                addBlockAtIndex(3)
            }
        } else if timeElapsed < level3 && timeElapsed >= level2 {
            if addedLevel != 2 {
                addedLevel = 2
                addBlockAtIndex(2)
            }
        } else if timeElapsed < level2 && timeElapsed >= level1 {
            if addedLevel != 1 {
                addedLevel = 1
                addBlockAtIndex(1)
            }
        } else if timeElapsed < level1 && timeElapsed >= level0 {
            if addedLevel != 0 {
                addBlockAtIndex(0)
                addedLevel = 0
            }
        }
    }
}
