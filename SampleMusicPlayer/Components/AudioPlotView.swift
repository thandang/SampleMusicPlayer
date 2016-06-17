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
import UIKit

struct AudioPoint {
    var x: GLfloat
    var y: GLfloat
    
    init() {
        x = 0.0
        y = 0.0
    }
}

struct AudioGLPlotInfo {
    var interpolated: Bool
    var points: UnsafeMutablePointer<AudioPoint>?
    var pointCount: Int
    var vbo: GLuint
    var vab: GLuint
    init() {
        interpolated = false
        pointCount = 0
        vbo = 0
        vab = 0
    }
}

class AudioPlotView: GLKView {
    var myColor: UIColor? {
        didSet {
            if let _ = myColor {
                let colorRef = myColor!.CGColor
                let componentCount = CGColorGetNumberOfComponents(colorRef)
                if (componentCount == 4) {
                    let components: UnsafePointer<CGFloat>  = CGColorGetComponents(colorRef)
                    let red = components[0]
                    let green = components[1]
                    let blue = components[2]
                    let alpha = components[3]
                    baseEffect?.constantColor = GLKVector4Make(Float(red), Float(green), Float(blue), Float(alpha))
                }
            } else {
                baseEffect?.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0)
            }
        }
    }
    var gain: float2?
    var shouldFill: Bool = false
    let DefaultMaxBufferLength = 8192
    
    private var baseEffect: GLKBaseEffect!
    var displayLink: AudioDisplayLink?
    private var info: AudioGLPlotInfo!
    private var localContext: EAGLContext!
    var timeInterval: Float = 0
    
    var blocks: [BlockObject] = []
    
    var projectionMatrix: GLKMatrix4?
    
    var customLoop: NTLoop?
    
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
        localContext = context
        setup()
    }
    
    override func drawRect(rect: CGRect) {
        redraw()
    }
    
    func setup() {
        let aspectRatio = frame.size.width / frame.size.height;
        projectionMatrix = GLKMatrix4MakeScale(1.0, aspectRatio.f, 1.0);
        info = AudioGLPlotInfo()
        memset(&info, 0, sizeof(AudioGLPlotInfo))
        info.pointCount = DefaultMaxBufferLength
        
        info.points = UnsafeMutablePointer<AudioPoint>.alloc(DefaultMaxBufferLength * sizeof(AudioPoint)) //allocate memory
        info.interpolated = true
        
        setupOpenGL()
        
        let bgColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.backgroundColor = bgColor
        let colorRef = bgColor.CGColor
        let componentCount = CGColorGetNumberOfComponents(colorRef)
        if (componentCount == 4) {
            let components: UnsafePointer<CGFloat>  = CGColorGetComponents(colorRef)
            let red = components[0]
            let green = components[1]
            let blue = components[2]
            let alpha = components[3]
            glClearColor(Float(red), Float(green), Float(blue), Float(alpha));
        }
    
        displayLink = AudioDisplayLink.init(delegate: self)
        displayLink?.start()
    }
    
    func setupOpenGL() {
        baseEffect = GLKBaseEffect()
        baseEffect.useConstantColor = GLboolean(GL_TRUE)
//        baseEffect.light0.enabled = GLboolean(GL_TRUE)
//        baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1.0)
        
        EAGLContext.setCurrentContext(localContext)
        
        drawableColorFormat = .RGBA8888
        drawableDepthFormat = .Format24
        drawableStencilFormat = .Format8
        drawableMultisample = .Multisample4X
        opaque = false
        enableSetNeedsDisplay = false
        
        if let _ = info { //Setup VBO
            glGenBuffers(1, &info!.vbo)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), info!.vbo)
            glBufferData(GLenum(GL_ARRAY_BUFFER),
                         info!.pointCount * sizeof(AudioPoint),
                         info!.points!,
                         GLenum(GL_STREAM_DRAW))
        }
    }
    
    deinit {
        displayLink?.stop()
        if  let _ = info {
            glDeleteBuffers(1, &info!.vbo)
            if let _ = info!.points {
                free(&info!.points!)
            }
            free(&info!)
        }
        baseEffect = nil
    }
    
    
    /**
     *  Clear screen
     */
    func clear() {
        let empltyBuffer:UnsafeMutablePointer<Float> = nil
        empltyBuffer[0] = 0.0
        setSampleData(empltyBuffer, length: 1)
        display()
    }
    
    /**
     Pause drawing
     */
    func pauseDrawing() {
        displayLink?.stop()
    }
    
    /**
     *  Resume drawing
     */
    func resumeDrawing() {
        displayLink?.start()
    }
}

//MARK: DRAW
extension AudioPlotView {
    
    func redraw() {
        guard let ino = info else {
            return
        }
        
        redrawingWithPoint(ino.points!, pointsCount: UInt32(ino.pointCount), baseEffect: baseEffect!, vertexBufferObject: ino.vbo, vertexArrayBuffer: ino.vab, interpolated: ino.interpolated, mird: false, gn: 1.0)
    }

    /**
     *  Redrawing With Points
     */
    func redrawingWithPoint(points: UnsafeMutablePointer<AudioPoint>,
                            pointsCount count: UInt32,
                            baseEffect effect:GLKBaseEffect,
                            vertexBufferObject vbo: GLuint,
                            vertexArrayBuffer vab: GLuint,
                            interpolated interd: Bool,
                            mird mirrored: Bool,
                            gn gain: Float) {
        glClearColor(0.1, 0.1, 0.1, 1.0)
        myColor = UIColor(red: 229.0/255, green: 181.0/255, blue: 17.0/255, alpha: 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glLineWidth(25.0)
        let mode = GLenum(GL_LINES)
        let interpolatedFator = interd ? 2.0 : 1.0
        let xScale = 2.0 / (Double(count) / interpolatedFator)
        let yScale = 1.0 * gain + 0.2
        let yScale2 = 1.0 * gain
        var transform = GLKMatrix4MakeTranslation(-1.0, 0.0, 0.0)
        transform = GLKMatrix4Scale(transform, Float(xScale), yScale, 1.0)
        baseEffect.transform.modelviewMatrix = transform
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo);
        baseEffect.prepareToDraw()
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue));
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue),
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(sizeof(AudioPoint)),
                              nil);
        glDrawArrays(mode, 0, GLsizei(count));
        
        myColor = UIColor(red: 56.0/255, green: 190.0/255, blue: 9.0/255, alpha: 1.0)
        var newTransform = GLKMatrix4MakeTranslation(-1.0, 0.0, 0.0)
        newTransform = GLKMatrix4Scale(newTransform, Float(xScale), Float(yScale2), 1.0)
        baseEffect.transform.modelviewMatrix = newTransform
        let newMode = GLenum(GL_LINES)
        
        baseEffect.prepareToDraw()
        glDrawArrays(newMode, 0, GLsizei(count))
        
        
        if blocks.count != 0 {
            glEnable(GLenum(GL_BLEND))
            glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
            for bl in blocks {
                bl.renderWithProjection(projectionMatrix!)
            }
        }
    }
    
    /**
     Update buffer when playing music. Invoke from controller to update frame from audio buffer
     
     - parameter buffer: buffer data
     - parameter size:   buffer size, it's UInt32 type but we expect Int type
     */
    func updateBuffer(buffer: UnsafeMutablePointer<Float>, withBufferSize size: UInt32) {
        setSampleData(buffer, length: Int(size))
    }
    
    func setSampleData(data: UnsafeMutablePointer<Float>, length: Int) {
        let points = info?.points
        addBlockAtPoint(CGPointMake(0.5, 0.5))
        if let _ = points {
            for i in 0.stride(to: length, by: 10) {
                points![i * 2].x = Float(i)
                points![i * 2 + 1].x = Float(i)
                var yValue: Float = data[i]
                if yValue < 0 {
                    yValue *= -1
                }
                if yValue > 0.2 {
//                    if blocks.count == 0 {
//                        addBlockAtPoint(CGPointMake(CGFloat(i), CGFloat(yValue + 0.3)))
//                    } else {
//                        var shouldAdd = true
//                        for bl in blocks {
//                            if bl.pointStoredX == Float(i) {
//                                shouldAdd = false
//                                break
//                            }
//                        }
//                        if shouldAdd {
//                            addBlockAtPoint(CGPointMake(CGFloat(i), CGFloat(yValue + 0.2)))
//                        }
//                    }
                }
                points![i * 2].y = yValue
                points![i * 2 + 1].y = 0.0
            }
            points![0].y = 0.0
            points![length - 1].y = 0.0
            info?.pointCount = length
            info?.interpolated = true
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), (info?.vbo)!)
            glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, length * sizeof(AudioPoint), points!)
        }
    }
}

//MARK: Draw block
extension AudioPlotView {
    func addBlockAtPoint(point: CGPoint) {
        let glPoint = CGPointMake(point.x/frame.size.width, point.y/frame.size.height);
        let x = (glPoint.x * 2.0) - 1.0;
        let block = BlockObject(texture: "block_64.png", position: GLKVector2Make(x.f, point.y.f))
        block.pointStoredX = point.x.f
        block.pointStoredY = point.y.f
        blocks.append(block)
    }
    
    func updateBlock() {
        if blocks.count > 0 {
            for bl in blocks {
                let aLive = bl.updateLifeCycle(timeInterval)
                if !aLive {
                    let tmp = blocks.arrayRemovingObject(bl)
                    blocks = tmp
                }
            }
        }
        print("blocks count: \(blocks.count)")
    }
    
    private func customDrawPoint() {
        glClearColor(0.2, 0.2, 0.2, 1.00)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        for bl in blocks {
            bl.renderWithProjection(projectionMatrix!)
        }
    }
}


//MARK: run loop display link
extension AudioPlotView: AudioDisplayLinkDelegate {
    func displayLinkNeedDisplay(link: AudioDisplayLink) {
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            timeInterval += Float(link.timeSinceLastUpdate)
            updateBlock()
            display()
        }
    }
}
