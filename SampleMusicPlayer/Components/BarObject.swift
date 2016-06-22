//
//  BarObject.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/21/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation

class BarObject: NSObject {
    private var particleBuffer: GLuint = 0
    var isDown: Bool = false
    private var barShader: BarShader?
    private var bar: Bar?
    private var texture: GLuint?
    private var position: GLKVector2!
    private var delta: Float = 0.0
    private var currentPosition: GLKVector2!
    
    init(position_: GLKVector2) {
        super.init()
        particleBuffer = 0
        position = position_
        currentPosition = position_
        texture = loadTexture("bar_64.png")
        loadShader()
        loadParticles()
    }
    
    func renderBarWithProjection(projectMatrix: GLKMatrix4) {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer)
        
        //Handle uniform
        
        if let _ = barShader {
            glActiveTexture(GLenum(GL_TEXTURE0))
            glBindTexture(GLenum(GL_TEXTURE_2D), texture!)
            glUniformMatrix4fv((barShader!.u_ProjectionMatrix)!, 1, GLboolean(GL_FALSE), projectMatrix.array)
            glUniform2f(barShader!.u_ePosition!, position.x, position.y)
            glUniform1f(barShader!.u_eSizeStart!, bar!.eSizeStart!)
            glUniform1f(barShader!.u_eSizeEnd!, bar!.eSizeEnd!)
            glUniform1i(barShader!.u_Texture!, 0);
            
            glUniform1f(barShader!.u_eDelta!, delta)
            
//            glEnableVertexAttribArray(GLenum(barShader!.a_pPositionYOffset!))
//            glVertexAttribPointer(GLenum(barShader!.a_pPositionYOffset!), 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(numberOfPointBar), nil)
            // Draw particles
//            glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(numberOfPointBar))
//            glDisableVertexAttribArray(GLenum((barShader!.a_pPositionYOffset)!))
            
            glDrawArrays(GLenum(GL_POINTS), 0, GLsizei(1))
        }
    }
    
    func updateLifeCycle(timeElapsed: Float) -> Bool {
        currentPosition = position
        delta = delta - 0.15
        if delta < -0.5 {
            return false
        }
        
        if position.y <= 0.0 {
            return false
        } else {
            return true
        }
    }
    
    
    private func loadShader() {
        barShader = BarShader()
        if let _ = barShader {
            barShader!.loadShader()
            if let program = barShader!.program {
                glUseProgram(program)
            }
        }
    }
    
    private func loadParticles() {
        var aBar = Bar()
        for i in 0...(numberOfPointBar - 1) {
            aBar.eParticles[i].pSizeOffset = 0.05
            aBar.eParticles[i].pPositionOffset = 0.5
        }
        aBar.eSizeStart = 32.0
        aBar.eSizeEnd = 32.0
        bar = aBar
        
        glGenBuffers(1, &particleBuffer);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), particleBuffer);
        glBufferData(GLenum(GL_ARRAY_BUFFER), numberOfPointBar, bar!.eParticles, GLenum(GL_STREAM_DRAW))
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
}
