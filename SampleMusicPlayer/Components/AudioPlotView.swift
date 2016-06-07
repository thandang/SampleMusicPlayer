//
//  AudioPlotView.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/7/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import GLKit
import OpenGLES.ES2

struct AudioPoint {
    let x: GLfloat
    let y: GLfloat
}

struct AudioGLPlotInfo {
    let interpolated: Bool
    let point: AudioPoint
    let plotHistoryInfo: PlotHistoryInfo
    let pointCount: UInt32
    var vob: GLuint
    var vab: GLuint
}

struct PlotHistoryInfo {
    let buffer: float2
    let bufferSize: Int
}

class AudioPlotView: GLKView {
    var color: UIColor?
    var gain: float2?
    var souldFill: Bool = false
    
    private var baseEffect: GLKBaseEffect?
    private var displayLink: AudioDisplayLink?
    private var info: AudioGLPlotInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect, context: EAGLContext) {
        super.init(frame: frame, context: context)
        setup()
    }
    
    
    /**
     *  Clear screen
     */
    func clear() {
        
    }
    
    /**
     Pause drawing
     */
    func pauseDrawing() {
        
    }
    
    /**
     *  Resume drawing
     */
    func resumeDrawing() {
        
    }
    
    func setupOpenGL() {
        baseEffect = GLKBaseEffect()
//        baseEffect?.useConstantColor = GL_TRUE
        

        drawableColorFormat = .RGBA8888
        drawableDepthFormat = .Format24
        drawableStencilFormat = .Format8
        drawableMultisample = .Multisample4X
        opaque = false
        enableSetNeedsDisplay = false
        
        
        
        
        
        if let _ = info {
            glGenBuffers(1, &info!.vob)
//            glBindBuffer(GL_ARRAY_BUFFER, info!.vob)
            
        }
        
    
//
//    glBindBuffer(GL_ARRAY_BUFFER, info.vbo);
//    glBufferData(GL_ARRAY_BUFFER, info
//    self.info->pointCount * sizeof(EZAudioPlotGLPoint),
//    self.info->points,
//    GL_STREAM_DRAW);
//    #if !TARGET_OS_IPHONE
//    [self.openGLContext unlock];
//    #endif
//    self.frame = self.frame;
    }
}

extension AudioPlotView {
    /**
     *  Redrawing With Points
     */
    func redrawingWithPoint(points: AudioPoint,
                            pointsCount count: UInt32,
                            baseEffect effect:GLKBaseEffect,
                            vertexBufferObject vbo: GLuint,
                            vertexArrayBuffer vab: GLuint,
                            interpolated interd: Bool,
                            mird mirrored: Bool,
                            gn gain: float2) {
        
    }
    
    func setup() {
        
    }
    
    func redraw() {
        
    }
    
    func updateBuffer(buffer: float2, bufferSize size: UInt32) {
        
    }
}

extension AudioPlotView: AudioDisplayLinkDelegate {
    func displayLinkNeedDisplay(link: AudioDisplayLink) {
        
    }
}
