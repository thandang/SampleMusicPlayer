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
    var x: GLfloat
    var y: GLfloat
    
    init() {
        x = 0.0
        y = 0.0
    }
}

struct AudioGLPlotInfo {
    var interpolated: Bool
//    var points: [AudioPoint]?
    var points: UnsafeMutablePointer<AudioPoint>?
    var plotHistoryInfo: PlotHistoryInfo?
    var pointCount: Int
    var vbo: GLuint
    var vab: GLuint
    init() {
        interpolated = false
        pointCount = 0
        points = nil
        vbo = 0
        vab = 0
    }
}

struct PlotHistoryInfo {
    var buffer: float2
    var bufferSize: Int
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
                baseEffect?.constantColor = GLKVector4Make(0.0, 0.0, 0.0, 0.0)
            }
        }
    }
    var gain: float2?
    var souldFill: Bool = false
    let DefaultMaxBufferLength = 8192
    
    private var baseEffect: GLKBaseEffect!
    private var displayLink: AudioDisplayLink?
    private var info: AudioGLPlotInfo!
    private var localContext: EAGLContext!
    
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
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        redraw()
    }
    
    func setup() {
        info = AudioGLPlotInfo()
        memset(&info, 0, sizeof(AudioGLPlotInfo))
        info.pointCount = DefaultMaxBufferLength
        
        info.points = UnsafeMutablePointer<AudioPoint>.alloc(DefaultMaxBufferLength) //allocate memory
        info.points?.initialize(AudioPoint()) //initialize memory
        
        info.interpolated = true
        self.backgroundColor = UIColor(red: 0.57, green: 0.82, blue: 0.48, alpha: 1.0)
        myColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        setupOpenGL()
        
        displayLink = AudioDisplayLink.init(delegate: self)
        displayLink?.start()
    }
    
    deinit {
        displayLink?.stop()
        if  let _ = info {
            glDeleteBuffers(1, &info!.vbo)
            free(&info!.points)
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
    
    func setupOpenGL() {
        baseEffect = GLKBaseEffect()
        baseEffect.useConstantColor = GLboolean(GL_TRUE)
        let ctx = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(ctx)
        
        drawableColorFormat = .RGBA8888
        drawableDepthFormat = .Format24
        drawableStencilFormat = .Format8
        drawableMultisample = .Multisample4X
        opaque = false
        enableSetNeedsDisplay = false
        
        if let _ = info {
            glGenBuffers(1, &info!.vbo)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), info!.vbo)
            glBufferData(GLenum(GL_ARRAY_BUFFER),
                         info!.pointCount * sizeof(AudioPoint),
                         &info!.points,
                         GLenum(GL_STREAM_DRAW))
        }
        
        frame = frame
    }
}

extension AudioPlotView {
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
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        let mode = GLenum(GL_TRIANGLE_STRIP)
        let interpolatedFator = interd ? 2.0 : 1.0
        let xScale = 2.0 / (Double(count) / interpolatedFator)
        let yScale = 1.0 * gain
        
        var transform = GLKMatrix4MakeTranslation(-1.0, 0.0, 0.0)
        transform = GLKMatrix4Scale(transform, Float(xScale), yScale, 0.0)
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
    }
    
    func redraw() {
        guard let ino = info else {
            return
        }
        
        redrawingWithPoint(ino.points!, pointsCount: UInt32(ino.pointCount), baseEffect: baseEffect!, vertexBufferObject: ino.vbo, vertexArrayBuffer: ino.vab, interpolated: ino.interpolated, mird: true, gn: 1)
    }

    /**
     Update buffer when playing music
     
     - parameter buffer: buffer data
     - parameter size:   buffer size, it's UInt32 type but we expect Int type
     */
    func updateBuffer(buffer: UnsafeMutablePointer<Float>, bufferSize size: UInt32) {
        setSampleData(buffer, length: Int(size))
    }
    
    func setSampleData(data: UnsafeMutablePointer<Float>, length: Int) {
        let pointCount = length * 2
        let points = info?.points
        if let _ = points {
            for i in 0...length {
                points![i * 2].x = Float(i)
                points![i * 2 + 1].x = Float(i)
                var yValue: Float = data[i]
                if yValue < 0 {
                    yValue *= 1
                }
                points![i * 2].y = yValue
                points![i * 2 + 1].y = 0.0
            }
        }
        
        points![0].y = 0.0
        points![pointCount - 1].y = 0.0
        info?.pointCount = pointCount
        info?.interpolated = true
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), (info?.vbo)!)
        glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, pointCount * sizeof(AudioPoint), points!)
    }
}

extension AudioPlotView: AudioDisplayLinkDelegate {
    func displayLinkNeedDisplay(link: AudioDisplayLink) {
//        display()
        drawRect(frame)
//        setNeedsDisplay()
    }
}
