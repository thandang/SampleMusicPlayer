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
    private var life: Float = 0.0
    private var timeElapse: Float = 0.0
    private var particleBuffer: GLuint?
    private var gravity: GLKVector2?
    var pointStoredX: Float = 0
    var pointStoredY: Float = 0
    
    
    var blockShader: BlockShader?
    var block: Block?
    
    var baseEffect: GLKBaseEffect?
    
    init(texture: String, position: GLKVector2) {
        super.init()
        life = 0.0
        timeElapse = 0.0
        particleBuffer = 0
        loadShader()
        loadTexture(texture)
        loadParticles(position)
    }
    
    func renderWithProjection(projectMatrix: GLKMatrix4) {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer!)
        
        //Handle uniform
        if let _ = blockShader {
            glUniformMatrix4fv((blockShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
            glUniform2f(blockShader!.u_Gravity!, gravity!.x, gravity!.y)
            glUniform1f(blockShader!.u_Time!, timeElapse)
            glUniform2f(blockShader!.u_ePosition!, block!.ePosition!.x, block!.ePosition!.y)
            glUniform1f(blockShader!.u_eRadius!, block!.eRadius!)
            glUniform1f(blockShader!.u_eVelocity!, block!.eVelocity!)
            glUniform1f(blockShader!.u_eDecay!, block!.eDecay!);
            glUniform1f(blockShader!.u_eSizeStart!, block!.eSizeStart!)
            glUniform1f(blockShader!.u_eSizeEnd!, block!.eSizeEnd!)
            glUniform1i(blockShader!.u_Texture!, 0);
            
            
            // Attributes
            glEnableVertexAttribArray(GLenum(blockShader!.a_pID!))
            glEnableVertexAttribArray(GLenum(blockShader!.a_pRadiusOffset!))
            glEnableVertexAttribArray(GLenum(blockShader!.a_pVelocityOffset!))
            glEnableVertexAttribArray(GLenum(blockShader!.a_pDecayOffset!))
            glEnableVertexAttribArray(GLenum(blockShader!.a_pSizeOffset!))
            glEnableVertexAttribArray(GLenum(blockShader!.a_pColorOffset!))
            
            glVertexAttribPointer(GLenum(blockShader!.a_pID!), 1,
                                  GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                                  GLsizei(strideof(Particles)), nil)
            glVertexAttribPointer(GLenum(blockShader!.a_pRadiusOffset!), 1,
                                  GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                                  GLsizei(strideof(Particles)), nil)
            glVertexAttribPointer(GLenum(blockShader!.a_pVelocityOffset!), 1,
                                  GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                                  GLsizei(strideof(Particles)), nil)
            glVertexAttribPointer(GLenum(blockShader!.a_pDecayOffset!), 1,
                                  GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                                  GLsizei(strideof(Particles)), nil)
            glVertexAttribPointer(GLenum(blockShader!.a_pSizeOffset!), 1,
                                  GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                                  GLsizei(strideof(Particles)), nil)
            glVertexAttribPointer(GLenum(blockShader!.a_pColorOffset!), 3,
                                  GLenum(GL_FLOAT), GLboolean(GL_FALSE),
                                  GLsizei(strideof(Particles)), nil)
            if let _ = baseEffect {
                baseEffect!.transform.modelviewMatrix = projectMatrix
                baseEffect!.prepareToDraw()
            }
            // Draw particles
            glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(1));
            glDisableVertexAttribArray(GLenum(blockShader!.a_pID!));
            glDisableVertexAttribArray(GLenum(blockShader!.a_pRadiusOffset!));
            glDisableVertexAttribArray(GLenum(blockShader!.a_pVelocityOffset!));
            glDisableVertexAttribArray(GLenum(blockShader!.a_pSizeOffset!));
            glDisableVertexAttribArray(GLenum(blockShader!.a_pColorOffset!));
        }
    }
    
    func updateLifeCycle(timeElapsed: Float) -> Bool {
        timeElapse += timeElapsed
        //Hardcode life
//        if(timeElapse < life) {
        if(timeElapse < 1.5) {
            return true;
        } else {
            return false
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
    
    private func loadParticles(position: GLKVector2) {
        var aBlock = Block()
        
        // Offset bounds
        let oRadius: Float = 0.10;      // 0.0 = circle; 1.0 = ring
        let oVelocity: Float = 0.50;    // Speed
        let oDecay: Float = 0.25;       // Time
        let oSize: Float = 8.00;        // Pixels
        
        aBlock.eParticles[0].pRadiusOffset = Float.random(min: -oRadius, max: oRadius)
        aBlock.eParticles[0].pVelocityOffset = Float.random(min: -oVelocity, max: oVelocity)
        aBlock.eParticles[0].pID = GLKMathDegreesToRadians(0.5*360.0)
        aBlock.eParticles[0].pDecayOffset = Float.random(min: -oDecay, max: oDecay)
        aBlock.eParticles[0].pColorOffset = GLKVector3Make(0.7, 0.7, 0.7)
        aBlock.eParticles[0].pSizeOffset = Float.random(min: -oSize, max: oSize)
        
        aBlock.ePosition = position
        aBlock.eRadius = 0.75
        aBlock.eDecay = 2.0
        aBlock.eVelocity = 1.0
        aBlock.eSizeEnd = 32.0
        aBlock.eSizeStart = 32.0
        
        let growth = aBlock.eRadius! / aBlock.eVelocity!
        life  = growth + aBlock.eDecay! + oDecay
        let drag:Float = 10.0
        gravity = GLKVector2Make(0.0, -9.81*(1.0/drag))
        block = aBlock
        
        
        glGenBuffers(1, &particleBuffer!);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer!);
        glBufferData(GLenum(GL_ARRAY_BUFFER), 1, block!.eParticles, GLenum(GL_STREAM_DRAW));
    }
}
