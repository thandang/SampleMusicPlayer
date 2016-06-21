//
//  BlockObject.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/16/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import OpenGLES
import CoreGraphics
import QuartzCore
import ImageIO

struct Particles {
    
    var pSizeOffset: Float?
    var pColorOffset: GLKVector3?
}

struct Block {
    var eParticles: [Particles] = [Particles()]
    var ePosition: GLKVector2?
    var eSizeStart: Float?
    var eSizeEnd: Float?
    
}

struct Bar {
    var eParticles: [Particles] = [Particles()]
    var ePosition: GLKVector2?
    var eSizeStart: Float?
    var eSizeEnd: Float?
}

struct BarColor {
    var colors = [1.0, 1.0, 1.0, 1.0]
}

class BlockObject: NSObject {
    let limittedLifeCycle: Float = 2.0
    private var life: Float = 0.0
    private var delta: Float = 0.0
    private var delta2: Float = 0.0
    var isDown: Bool = true

    private var particleBuffer: GLuint = 0
    private var particleBuffer2: GLuint = 0
    private var secondPostionY: Float = 0
    var pointStoredX: Float = 0
    var pointStoredY: Float = 0
    var positionStored: GLKVector2!
    var currentPosition: GLKVector2!
    var blockShader: BlockShader?
    var block: Block?
    
    var barShader: BarShader?
    var bar: Bar?
    
    var baseEffect: GLKBaseEffect?
    
    var pointInfo: AudioGLPlotInfo!
    
    var firstTexture: GLuint?
    var secondTexture: GLuint?
    
    let paraVertex: [GLfloat] = [50,270,
                                 100,30,
                                 54,270,
                                 104,30,
                                 58,270,
                                 108,30]
    let paraColor: [GLfloat] = [1,1,1,    //white
        1,1,1,
        1,0,0,    //red
        1,0,0,
        1,1,1,    //white
        1,1,1]
    
    init(texture: String, position: GLKVector2) {
        super.init()
        life = 0.0
        loadShader()
        
        firstTexture = loadTexture("block_64.png")
        secondTexture = loadTexture("bar_64.png")
        
        pointInfo = AudioGLPlotInfo()
        memset(&pointInfo, 0, sizeof(AudioGLPlotInfo))
        pointInfo.pointCount = DefaultMaxBufferLength
        
        pointInfo.points = UnsafeMutablePointer<AudioPoint>.alloc(DefaultMaxBufferLength * sizeof(AudioPoint)) //allocate memory
        loadParticles()
        positionStored = position
        currentPosition = position
    }
    
    func renderWithProjection(projectMatrix: GLKMatrix4) {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer)
        
        //Handle uniform
        if let _ = blockShader {
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), firstTexture!)
            glUniformMatrix4fv((blockShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
            glUniform2f(blockShader!.u_ePosition!, positionStored.x, positionStored.y) //Using real time position instead
            glUniform1f(blockShader!.u_eSizeStart!, block!.eSizeStart!)
            glUniform1f(blockShader!.u_eSizeEnd!, block!.eSizeEnd!)
            glUniform1i(blockShader!.u_Texture!, 0);
            
            glUniform1f(blockShader!.u_eDelta!, delta)
            
            
//            if let _ = baseEffect {
//                baseEffect!.transform.modelviewMatrix = projectMatrix
//                baseEffect!.prepareToDraw()
//            }
            
            // Draw particles
            glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(1));
        }
    }
    
    
    func renderBar(projectMatrix: GLKMatrix4) {
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer2)
        
        //Handle uniform
        
        if let _ = barShader {
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), secondTexture!)
            glUniformMatrix4fv((barShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
            glUniform2f(barShader!.u_ePosition!, positionStored.x, secondPostionY) //Using real time position instead
            glUniform1f(barShader!.u_eSizeStart!, bar!.eSizeStart!)
            glUniform1f(barShader!.u_eSizeEnd!, bar!.eSizeEnd!)
            glUniform1i(barShader!.u_Texture!, 0);
            
            glUniform1f(barShader!.u_eDelta!, delta2)
            
            if let _ = baseEffect {
                baseEffect!.transform.modelviewMatrix = projectMatrix
                baseEffect!.prepareToDraw()
            }
            
            // Draw particles
            glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(1))
        }

//        glEnable(GLenum(GL_LINE_SMOOTH));
//        glHint(GLenum(GL_LINE_SMOOTH_HINT), GLenum(GL_NICEST));
//        glEnable(GLenum(GL_BLEND));
//        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
//        glEnableClientState(GLenum(GL_VERTEX_ARRAY))
//        glEnableClientState(GLenum(GL_COLOR_ARRAY))
//
//        
//        glVertexPointer(2, GLenum(GL_FLOAT), 0, paraVertex);
//        glColorPointer(3, GLenum(GL_FLOAT), 0, paraColor);
//        glDrawArrays(GLenum(GL_LINES), 0, 6);
        
        
//        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
//        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue),
//                              2,
//                              GLenum(GL_FLOAT),
//                              GLboolean(GL_FALSE),
//                              2 * 4,
//                              nil)
//        glDrawArrays(GLenum(GL_LINES), 0, 2)

        
        
        //For draw line
        
//        glLineWidth(32.0)
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), pointInfo.vbo);
//        
//        let points = pointInfo.points
//        if let _ = points {
//            points![0].x = positionStored.x
//            points![0].y = positionStored.y
//            glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, 1, points!)
//        }
//
//        glUniformMatrix4fv(blockShader!.u_ProjectionMatrix2!, 1, GLboolean(GL_FALSE), projectMatrix.array)
//        
//        //Could we replace with an attribute from glsl
//        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue));
//        glEnableVertexAttribArray(GLuint((barShader?.u_eColor)!))
//        
//        glVertexAttribPointer(GLuint((barShader?.u_eColor)!), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideof(BarColor)), nil)
//        
//        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue),
//                              2,
//                              GLenum(GL_FLOAT),
//                              GLboolean(GL_FALSE),
//                              GLsizei(sizeof(AudioPoint)),
//                              nil)
//
//        glDrawArrays(GLenum(GL_LINES), 0, GLsizei(512));
//        glDisableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
//        glDisableVertexAttribArray(GLuint((barShader?.u_eColor)!))
    }
    
    func updateBarData(data: UnsafeMutablePointer<Float>, length: Int) {
        let points = pointInfo.points
        if let _ = points {
            for i in 0.stride(to: length, by: 1) {
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
            pointInfo.pointCount = length
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), (pointInfo.vbo))
            glBufferSubData(GLenum(GL_ARRAY_BUFFER), 0, length * sizeof(AudioPoint), points!)
        }
    }
    
    func updateLifeCycle(timeElapsed: Float) -> Bool {
        //Only update yValue if bar is moving down
        if currentPosition.y == positionStored.y {
            isDown = true
        }
        currentPosition = positionStored
        secondPostionY = currentPosition.y - 0.05
        if isDown {
            delta2 = delta2 - 0.1
            delta = delta - 0.02
            if delta < -0.5 {
                return false
            }
        } else {
            delta = 0.0
            delta2 = 0.0
        }
        
        if positionStored.y <= 0.0 {
            return false
        } else {
            return true
        }
    }
    
    
    
    private func loadShader() {
        blockShader = BlockShader()
        if let _ = blockShader {
            blockShader!.loadShader()
            if let program = blockShader!.program {
                glUseProgram(program)
            }
        }
        
        barShader = BarShader()
        if let _ = barShader {
            barShader!.loadShader()
            if let program = barShader!.program {
                glUseProgram(program)
            }
        }
    }
    
    
    private func loadTexture(fileName: String) -> GLuint {
        let ref = UIImage(named: fileName)?.CGImage
        guard let refImage = ref else {
            exit(1)
        }
        let width = CGImageGetWidth(refImage)
        let height = CGImageGetHeight(refImage)
        let refData = UnsafeMutablePointer<Void>.alloc(width * height * 4)
        let imageContext = CGBitmapContextCreate(refData, width, height, 8, width * 4, CGImageGetColorSpace(refImage), CGImageAlphaInfo.PremultipliedLast.rawValue)
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height)), refImage)
        
        var textName: GLuint = 0
        glGenTextures(1, &textName)
        glBindTexture(GLenum(GL_TEXTURE_2D), textName)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_NEAREST))
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), refData)
      
        free(refData)
        return textName
    }
    
    private func loadParticles() { //setup VBO
        var aBar = Bar()
        aBar.eSizeStart = 32.0
        aBar.eSizeEnd = 32.0
        bar = aBar
        
        var aBlock = Block()
        aBlock.eSizeStart = 32.0
        aBlock.eSizeEnd = 32.0
        block = aBlock
        
        glGenBuffers(1, &particleBuffer);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer);
        glBufferData(GLenum(GL_ARRAY_BUFFER), 1, block!.eParticles, GLenum(GL_STREAM_DRAW));
        

        glGenBuffers(1, &particleBuffer2);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer2);
        glBufferData(GLenum(GL_ARRAY_BUFFER), 1, bar!.eParticles, GLenum(GL_STREAM_DRAW))
//        glBufferData(GLenum(GL_ARRAY_BUFFER), 1, lines, GLenum(GL_STREAM_DRAW))
        
//        For draw
//        glGenBuffers(1, &pointInfo!.vbo)
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), pointInfo!.vbo)
//        glBufferData(GLenum(GL_ARRAY_BUFFER),
//                     pointInfo!.pointCount * sizeof(AudioPoint),
//                     pointInfo!.points!,
//                     GLenum(GL_STREAM_DRAW))
    }
}
