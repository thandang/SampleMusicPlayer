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

let numberOfPointBar: Int = 8
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
    private var life: Float = 0.0
    private var delta: Float = 0.0
    private var delta2: Float = 0.0
    
    private var particleBuffer: GLuint = 0
    private var particleBuffer2: GLuint = 0
    private var secondPostionY: Float = 0
    private var numberOfStepItem: Int = 5 //Default value
    private var blockShader: BlockShader?
    private var block: Block?
    
    private var firstTexture: GLuint?
    private var secondTexture: GLuint?
    private var thirdTexture: GLuint?
    
    private var barShader: BarShader?
    private var bar: Bar?
    
    private let topColor: GLKVector3 = GLKVector3Make(239.0/255.0, 160.0/255.0, 51.0/255.0)
    private let limittedLifeCycle: Float = 2.0
    private let stepBar: Float = 0.1
    private let stepBlock: Float = 0.05
    private let distanceBar2Block: Float = 0.01
    private let pointSize: Float = 32.0
    private let haftPointSize: Float = 18.0
    private let pointSizeHeight: Float = 0.04
    private let plusX: Float = 0.011
    private let bottomY: Float = -0.3
    private let bottomYCap: Float = -0.26
    
    
    var pointStoredX: Float = 0
    var pointStoredY: Float = 0
    var positionStored: GLKVector2!
    var currentPosition: GLKVector2!
    
    var isDown: Bool = true
    
    
    init(texture: String, position: GLKVector2) {
        super.init()
        life = 0.0
        loadShader()
        
        firstTexture = loadTexture("block_64.png")
        secondTexture = loadTexture("bar_64.png")
        thirdTexture = loadTexture("bar_32.png")
        
        loadParticles()
        positionStored = position
        currentPosition = position
    }
    
    func renderWithProjection(projectMatrix: GLKMatrix4) {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer)
        
        //Handle uniform
        if let _ = blockShader {
            if positionStored.y + delta < bottomYCap {
                positionStored = GLKVector2Make(positionStored.x, bottomYCap) //Limit the bottom position for tear down
                delta = 0.0
            }
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), firstTexture!)
            glUniformMatrix4fv((blockShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
            glUniform2f(blockShader!.u_ePosition!, positionStored.x, positionStored.y) //Using real time position instead
            glUniform1f(blockShader!.u_eSizeStart!, block!.eSizeStart!)
            glUniform1f(blockShader!.u_eSizeEnd!, block!.eSizeEnd!)
            glUniform1i(blockShader!.u_Texture!, 0)
            glUniform1f(blockShader!.u_eDelta!, delta)
            
            // Draw particles
            glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(1));
        }
    }
    
    
    func renderBar(projectMatrix: GLKMatrix4) {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer2)
        glActiveTexture(GLenum(GL_TEXTURE0))
        
        if let _ = barShader {
            glBindTexture(GLenum(GL_TEXTURE_2D), secondTexture!)
            
            let step: Float = stepBlock
            var nextPosition: Float = bottomY
            for i in numberOfStepItem.stride(to: 0, by: -1) {
                nextPosition = bottomY - 0.01 + step * Float(i)
                if nextPosition > secondPostionY {
                    nextPosition = secondPostionY
                }
                
                if nextPosition + delta2 - 0.001 < bottomY {
                    break
                }
                glUniformMatrix4fv((barShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
                glUniform2f(barShader!.u_ePosition!, positionStored.x, nextPosition)
                glUniform1f(barShader!.u_eSizeStart!, bar!.eSizeStart!)
                glUniform1f(barShader!.u_eSizeEnd!, bar!.eSizeEnd!)
                glUniform1i(barShader!.u_Texture!, 0);
                glUniform1f(barShader!.u_eDelta!, delta2)
//                glUniform3f(barShader!.u_GrowthColor!, topColor.r, topColor.g, topColor.b)
                
                // Draw particles
                glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(numberOfPointBar))
            }
            
            //We always draw a point at the bottom
            glBindTexture(GLenum(GL_TEXTURE_2D), thirdTexture!)
            glUniformMatrix4fv((barShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
            glUniform2f(barShader!.u_ePosition!, positionStored.x - plusX, bottomY)
            
            glUniform1f(barShader!.u_eSizeStart!, haftPointSize)
            glUniform1f(barShader!.u_eSizeEnd!, haftPointSize)
            glUniform1i(barShader!.u_Texture!, 0)
            glUniform1f(barShader!.u_eDelta!, 0.0)
            glUniform3f(barShader!.u_GrowthColor!, topColor.r, topColor.g, topColor.b)
            
            // Draw particles
            glDrawArrays(GLenum(GL_POINTS), 0, 1)
            
            glBindTexture(GLenum(GL_TEXTURE_2D), thirdTexture!)
            glUniformMatrix4fv((barShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
            glUniform2f(barShader!.u_ePosition!, positionStored.x + plusX, bottomY)
            
            glUniform1f(barShader!.u_eSizeStart!, haftPointSize)
            glUniform1f(barShader!.u_eSizeEnd!, haftPointSize)
            glUniform1i(barShader!.u_Texture!, 0)
            glUniform1f(barShader!.u_eDelta!, 0.0)
            glUniform3f(barShader!.u_GrowthColor!, topColor.r, topColor.g, topColor.b)
            
            
            // Draw particles
            glDrawArrays(GLenum(GL_POINTS), 0, 1)
        }
    }
    
    
    
    func updateLifeCycle(timeElapsed: Float) {
        //Only update yValue if bar is moving down
        if currentPosition.y == positionStored.y {
            isDown = true
        }
        //We store the current position to calculate state of moving (up or down)
        currentPosition = positionStored
        
        //secondPositionY is used to draw bar, it's a little down of cap position
        secondPostionY = positionStored.y - distanceBar2Block
        
        //Calculate the number of item should we draw a bar
        numberOfStepItem = Int(positionStored.y / pointSizeHeight) + 8
        delta2 = delta2 - stepBar
        
        /* We calculate the velocity for cover
         * Next time we should move the calculate to glsl to make it works on Android too
        */
        if isDown {
            delta = delta - stepBlock
        } else {
            delta = 0.0
            delta2 = 0.0
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
        aBlock.eSizeStart = pointSize
        aBlock.eSizeEnd = pointSize
        block = aBlock
        
        glGenBuffers(1, &particleBuffer);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), 1, block!.eParticles, GLenum(GL_STREAM_DRAW))
        

        var aBar = Bar()
        for i in 0...(numberOfPointBar - 1) {
            aBar.eParticles[i].pSizeOffset = 0.05
            aBar.eParticles[i].pPositionOffset = 0.5
        }
        aBar.eSizeStart = pointSize
        aBar.eSizeEnd = pointSize
        bar = aBar
        glGenBuffers(1, &particleBuffer2);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer2);
        glBufferData(GLenum(GL_ARRAY_BUFFER), strideofValue(bar!.eParticles), bar!.eParticles, GLenum(GL_STREAM_DRAW))
    }
}
