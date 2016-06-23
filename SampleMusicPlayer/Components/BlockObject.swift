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
    var pPositionOffset: Float?
}

struct Block {
    var eParticles: [Particles] = [Particles()]
    var ePosition: GLKVector2?
    var eSizeStart: Float?
    var eSizeEnd: Float?
    
}

let numberOfPointBar: Int = 5
struct Bar {
    var eParticles = [Particles](count: numberOfPointBar, repeatedValue: Particles())
    var ePosition: GLKVector2?
    var eSizeStart: Float?
    var eSizeEnd: Float?
    var eGrowthColor: GLKVector3?
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
    
    private var shouldDisableBar: Bool = false

    private var particleBuffer: GLuint = 0
    private var particleBuffer2: GLuint = 0
    private var secondPostionY: Float = 0
    private var nextSecondPositionY: Float = 0
    private var numberOfStepItem: Int = 5 //Default value
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
    
    let topColor: GLKVector3 = GLKVector3Make(239.0/255.0, 160.0/255.0, 51.0/255.0)
    
    
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
            
            // Draw particles
            glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(1));
        }
    }
    
    
    func renderBar(projectMatrix: GLKMatrix4) {
        if !shouldDisableBar {
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
                glUniform3f(barShader!.u_GrowthColor!, topColor.r, topColor.g, topColor.b)
                
                glEnableVertexAttribArray(GLenum(barShader!.a_pPositionYOffset!))
                glVertexAttribPointer(GLenum(barShader!.a_pPositionYOffset!), 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(numberOfPointBar), nil)
                
                
                // Draw particles
                glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(numberOfPointBar))
                glDisableVertexAttribArray(GLenum((barShader!.a_pPositionYOffset)!))
                
                let step: Float = 0.05
                for i in 1...numberOfStepItem {
                    //Draw second
                    glUniformMatrix4fv((barShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
                    glUniform2f(barShader!.u_ePosition!, positionStored.x, secondPostionY - step * Float(i)) //Using real time position instead
                    
                    glEnableVertexAttribArray(GLenum(barShader!.a_pPositionYOffset!))
                    glVertexAttribPointer(GLenum(barShader!.a_pPositionYOffset!), 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(numberOfPointBar), nil)
                    
                    // Draw particles
                    glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(numberOfPointBar))
                    glDisableVertexAttribArray(GLenum((barShader!.a_pPositionYOffset)!))
                }
            }
        }
    }
    
    
    
    func updateLifeCycle(timeElapsed: Float) -> Bool {
        //Only update yValue if bar is moving down
        if currentPosition.y == positionStored.y {
            isDown = true
        }
        currentPosition = positionStored
        secondPostionY = currentPosition.y - 0.08
        nextSecondPositionY = secondPostionY - 0.5
        numberOfStepItem = Int(currentPosition.y / 0.07) + 5
        if isDown {
            delta2 = delta2 - 0.2
            if delta2 < -0.05 {
                shouldDisableBar = true
            }
            delta = delta - 0.05
            if delta < -0.7 {
                return false
            }
        } else {
            shouldDisableBar = false
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
        var aBlock = Block()
        aBlock.eSizeStart = 32.0
        aBlock.eSizeEnd = 32.0
        block = aBlock
        
        glGenBuffers(1, &particleBuffer);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), 1, block!.eParticles, GLenum(GL_STREAM_DRAW))
        

        var aBar = Bar()
        for i in 0...(numberOfPointBar - 1) {
            aBar.eParticles[i].pSizeOffset = 0.05
            aBar.eParticles[i].pPositionOffset = 0.5
        }
        aBar.eSizeStart = 32.0
        aBar.eSizeEnd = 32.0
//        aBar.pSourceColor = GLKVector3Make(239.0/255.0, 160.0/255.0, 51.0/255.0)
        bar = aBar
        glGenBuffers(1, &particleBuffer2);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer2);
        glBufferData(GLenum(GL_ARRAY_BUFFER), strideofValue(bar!.eParticles), bar!.eParticles, GLenum(GL_STREAM_DRAW))
    }
}
