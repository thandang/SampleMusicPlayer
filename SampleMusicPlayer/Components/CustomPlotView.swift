//
//  CustomPlotView.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/18/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation

class CustomPlotView: NSObject {
    
    private var info: AudioGLPlotInfo!
    
    private var baseEffect: GLKBaseEffect!
    
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
    
    
    override init() {
        super.init()
        setup()
    }
    
    func setup() {
        info = AudioGLPlotInfo()
        memset(&info, 0, sizeof(AudioGLPlotInfo))
        info.pointCount = DefaultMaxBufferLength
        
        info.points = UnsafeMutablePointer<AudioPoint>.alloc(DefaultMaxBufferLength * sizeof(AudioPoint)) //allocate memory
        info.interpolated = true
        
        setupOpenGL()
        
        let bgColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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
    }
    
    func setupOpenGL() {
        baseEffect = GLKBaseEffect()
        baseEffect?.useConstantColor = GLboolean(GL_TRUE)
        
        if let _ = info { //Setup VBO
            glGenBuffers(1, &info!.vbo)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), info!.vbo)
            glBufferData(GLenum(GL_ARRAY_BUFFER),
                         info!.pointCount * sizeof(AudioPoint),
                         info!.points!,
                         GLenum(GL_STREAM_DRAW))
        }
    }
    
    
    func redraw() {
        guard let ino = info else {
            return
        }
        
        redrawingWithPoint(ino.points!, pointsCount: UInt32(ino.pointCount), baseEffect: baseEffect!, vertexBufferObject: ino.vbo, vertexArrayBuffer: ino.vab, interpolated: ino.interpolated, mird: false, gn: 1.0)
    }
    
    /**
     *  Redrawing With Points
     */
    private func redrawingWithPoint(points: UnsafeMutablePointer<AudioPoint>,
                            pointsCount count: UInt32,
                                        baseEffect effect:GLKBaseEffect,
                                                   vertexBufferObject vbo: GLuint,
                                                                      vertexArrayBuffer vab: GLuint,
                                                                                        interpolated interd: Bool,
                                                                                                     mird mirrored: Bool,
                                                                                                          gn gain: Float) {
//        glClearColor(0.3, 0.3, 0.3, 1.00)
//        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        myColor = UIColor(red: 229.0/255, green: 181.0/255, blue: 17.0/255, alpha: 1.0)
        glLineWidth(32.0)
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
        
        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(count));
        
        myColor = UIColor(red: 56.0/255, green: 190.0/255, blue: 9.0/255, alpha: 1.0)
        var newTransform = GLKMatrix4MakeTranslation(-1.0, 0.0, 0.0)
        newTransform = GLKMatrix4Scale(newTransform, Float(xScale), Float(yScale2), 1.0)
        baseEffect.transform.modelviewMatrix = newTransform
        
        baseEffect.prepareToDraw()
        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(count))
    }
    
    /**
     Update buffer when playing music. Invoke from controller to update frame from audio buffer
     
     - parameter buffer: buffer data
     - parameter size:   buffer size, it's UInt32 type but we expect Int type
     */
    func updateBuffer(buffer: UnsafeMutablePointer<Float>, withBufferSize size: UInt32) {
        setSampleData(buffer, length: Int(size))
    }
    
    private func setSampleData(data: UnsafeMutablePointer<Float>, length: Int) {
        print("point count: \(length)")
        let points = info?.points
        if let _ = points {
            for i in 0.stride(to: length, by: 20) {
                points![i * 2].x = Float(i)
                points![i * 2 + 1].x = Float(i)
                var yValue: Float = data[i]
                if yValue < 0 {
                    yValue *= -1
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
