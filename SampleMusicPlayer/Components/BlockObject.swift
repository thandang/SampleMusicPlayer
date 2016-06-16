//
//  BlockObject.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/16/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation

struct Particles {
    var pID: Float?
    var pRadiusOffset: Float?
    var pVelocityOffset: Float?
    var pDecayOffset: Float?
    var pSizeOffset: Float?
    var pColorOffset: Float?
}

struct Block {
    var eParticles: [Particles]?
    var ePosition: GLKVector2?
    var eRadius: Float?
    var eVelocity: Float?
    var eDecay: Float?
    var eSizeStart: Float?
    var eSizeEnd: Float?
}

class BlockObject: NSObject {
    private var life: Float?
    private var timeElapse: Float = 0.0
    private var particleBuffer: GLuint?
    private var gravity: GLKVector2?
    
    var blockShader: BlockShader?
    var block: Block?
    
    init(texture: String?, position: GLKVector2) {
        super.init()
        life = 0.0
        timeElapse = 0.0
        particleBuffer = 1
        loadShader()
        loadTexture("block_64")
        loadParticles(position)
    }
    
    func renderWithProjection(projectMatrix: GLKMatrix4) {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer!)
        
        //Handle uniform
        
        glUniformMatrix4fv((blockShader?.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
        glUniform2f(blockShader!.u_Gravity!, gravity!.x, gravity!.y);
        glUniform1f(blockShader!.u_Time!, timeElapse);
        glUniform2f(blockShader!.u_ePosition!, block!.ePosition!.x, block!.ePosition!.y);
        glUniform1f(blockShader!.u_eRadius!, block!.eRadius!);
        glUniform1f(blockShader!.u_eVelocity!, block!.eVelocity!);
        glUniform1f(blockShader!.u_eDecay!, block!.eDecay!);
        glUniform1f(blockShader!.u_eSizeStart!, block!.eSizeStart!);
        glUniform1f(blockShader!.u_eSizeEnd!, block!.eSizeEnd!);
//        glUniform3f(blockShader!.u_eColorStart!, block!.eColorStart.r, block!.eColorStart.g, block!.eColorStart.b);
//        glUniform3f(blockShader!.u_eColorEnd!, block!.eColorEnd.r, block!.eColorEnd.g, block!.eColorEnd.b);
        glUniform1i(blockShader!.u_Texture!, 0);
        
        // Attributes
        glEnableVertexAttribArray(blockShader!.a_pID!);
        glEnableVertexAttribArray(blockShader!.a_pRadiusOffset!);
        glEnableVertexAttribArray(blockShader!.a_pVelocityOffset!);
        glEnableVertexAttribArray(blockShader!.a_pDecayOffset!);
        glEnableVertexAttribArray(blockShader!.a_pSizeOffset!);
        glEnableVertexAttribArray(blockShader!.a_pColorOffset!);
        
        glVertexAttribPointer(blockShader!.a_pID!, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Particles)), nil);
        glVertexAttribPointer(blockShader!.a_pRadiusOffset!, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Particles)), nil);
        glVertexAttribPointer(blockShader!.a_pVelocityOffset!, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Particles)), nil);
        
        glVertexAttribPointer(blockShader!.a_pSizeOffset!, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Particles)), nil);
        glVertexAttribPointer(blockShader!.a_pColorOffset!, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(sizeof(Particles)), nil);
        
        // Draw particles
        glDrawArrays(GLenum(GL_POINTS), 0, 1);
        glDisableVertexAttribArray(blockShader!.a_pID!);
        glDisableVertexAttribArray(blockShader!.a_pRadiusOffset!);
        glDisableVertexAttribArray(blockShader!.a_pVelocityOffset!);
        glDisableVertexAttribArray(blockShader!.a_pSizeOffset!);
        glDisableVertexAttribArray(blockShader!.a_pColorOffset!);
        
    }
    
    func updateLifeCycle(timeElapsed: Float) -> Bool {
        timeElapse += timeElapsed;
        
        if(timeElapse < life) {
            return true;
        } else {
            return false
        }
    }
    
    private func loadShader() {
        blockShader = BlockShader()
        if let _ = blockShader {
            blockShader!.loadShader()
            glUseProgram(blockShader!.program!)
        }
    }
    
    private func loadTexture(fileName: String) {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "png")
        let texture = try! GLKTextureLoader.textureWithContentsOfFile(path!, options: [GLKTextureLoaderOriginBottomLeft: NSNumber.init(bool: true)])
        
        glBindTexture(GLenum(GL_TEXTURE_2D), texture.name)
    }
    
    private func loadParticles(position: GLKVector2) {
        //TODO: setup data here
        let aBlock = Block()
        
        // Offset bounds
        
        let oRadius = 0.1
        let oVelocity = 0.5
        let oDecay = 0.25
        let oSize = 8.0
        let oColor = 0.25

        
        glGenBuffers(1, &particleBuffer!);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer!);
        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(Particles), (block!.eParticles)!, GLenum(GL_STATIC_DRAW));
    }
}
