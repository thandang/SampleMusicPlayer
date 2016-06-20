//
//  BlockObject.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/16/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import OpenGLES

struct Particles {
    var pID: Float?
    var pRadiusOffset: Float?
    var pVelocityOffset: Float?
    var pDecayOffset: Float?
    var pSizeOffset: Float?
    var pColorOffset: GLKVector3?
}

struct Block {
    var eParticles: [Particles] = [Particles()]
    var ePosition: GLKVector2?
    var eRadius: Float?
    var eVelocity: Float?
    var eDecay: Float?
    var eSizeStart: Float?
    var eSizeEnd: Float?
    
}

class BlockObject: NSObject {
    let limittedLifeCycle: Float = 2.0
    private var life: Float = 0.0
    private var delta: Float = 0.0
    var isDown: Bool = true

    private var particleBuffer: GLuint?
    private var gravity: GLKVector2?
    var pointStoredX: Float = 0
    var pointStoredY: Float = 0
    var positionStored: GLKVector2!
    var currentPosition: GLKVector2!
    var blockShader: BlockShader?
    var block: Block?
    
    var baseEffect: GLKBaseEffect?
    
    init(texture: String, position: GLKVector2) {
        super.init()
        life = 0.0
        particleBuffer = 0
        delta = 0.0
        loadShader()
        loadTexture(texture)
        loadParticles()
        positionStored = position
        currentPosition = position
    }
    
    func renderWithProjection(projectMatrix: GLKMatrix4) {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer!)
        
        //Handle uniform
        if let _ = blockShader {
            glUniformMatrix4fv((blockShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
            glUniform2f(blockShader!.u_ePosition!, positionStored.x, positionStored.y) //Using real time position instead
            glUniform1f(blockShader!.u_eSizeStart!, block!.eSizeStart!)
            glUniform1f(blockShader!.u_eSizeEnd!, block!.eSizeEnd!)
            glUniform1i(blockShader!.u_Texture!, 0);
            
            glUniform1f(blockShader!.u_eDelta!, delta)
            
            
            if let _ = baseEffect {
                baseEffect!.transform.modelviewMatrix = projectMatrix
                baseEffect!.prepareToDraw()
            }
            // Draw particles
            glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(1));
        }
    }
    
    func updateLifeCycle(timeElapsed: Float) -> Bool {
        //Only update yValue if bar is moving down
        if currentPosition.y == positionStored.y {
            isDown = true
        }
        currentPosition = positionStored
        if isDown {
            delta = delta - 0.01
            if delta < -0.5 {
                return false
            }
        } else {
            delta = 0.0
        }
        
        if positionStored.y < 0 {
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
    }
    
    private func loadTexture(fileName: String) {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: nil)
        if let p = path {
            if let texture = try? GLKTextureLoader.textureWithContentsOfFile(p, options: [GLKTextureLoaderOriginBottomLeft: NSNumber.init(bool: true)]) {
                glBindTexture(GLenum(GL_TEXTURE_2D), texture.name)
            }
        }
    }
    
    private func loadParticles() { //setup VBO
        var aBlock = Block()
        aBlock.eSizeStart = 32.0
        aBlock.eSizeEnd = 32.0
        block = aBlock
        
        glGenBuffers(1, &particleBuffer!);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer!);
        glBufferData(GLenum(GL_ARRAY_BUFFER), 1, block!.eParticles, GLenum(GL_STREAM_DRAW));
    }
}
