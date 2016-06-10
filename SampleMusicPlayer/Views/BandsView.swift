//
//  BandsView.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/6/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import OpenGLES.ES2
import GLKit

/// For disaplay brands view with OpenGL random brand name
struct Vertex {
    var positions: [Float]?
    var colors: [Float]?
}
class BrandsView: GLKView {
    var scoreTexture: GLKTextureInfo?
    var localContext: EAGLContext?
    var baseEffect: GLKBaseEffect?
    var modelViewProjectionMatrix: GLKMatrix4?
    var normalMatrix: GLKMatrix3?
    var rotation: Float?
    var vertexArray: GLuint?
    var vertexBuffer: GLuint?
    var arrayOfVertex:[GLuint]?
    let indices: [GLubyte] = [0, 1, 2,
                              2, 3, 0]
    
    
    
    override init(frame: CGRect) {
       super.init(frame: frame)
        drawsimpleBand()
        setupOpenGL()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupOpenGL()
    }
    
    
    override func drawRect(rect: CGRect) {
        
    }
    
    func setupOpenGL() {
        localContext = EAGLContext.init(API: .OpenGLES2)
        EAGLContext.setCurrentContext(localContext)
        baseEffect = GLKBaseEffect()
        baseEffect?.useConstantColor = GLboolean(GL_TRUE)
        
        drawableDepthFormat = .Format24
        
        baseEffect?.light0.enabled = GLboolean(GL_TRUE);
        baseEffect?.light0.diffuseColor = GLKVector4Make(1.0, 0.4, 0.4, 1.0);
        glEnable(GLenum(GL_DEPTH_TEST))
    }
    
    func setupVBOs() {
        glGenBuffers(1, &vertexArray!)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexArray!)
        
//        glBufferData(GLenum(GL_ARRAY_BUFFER), 0, <#T##data: UnsafePointer<Void>##UnsafePointer<Void>#>, <#T##usage: GLenum##GLenum#>)
    }
    
    func startDraw() {
        
    }
    
    func drawsimpleBand() {
        let size = CGSizeMake(100, 100)
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        let image = CGBitmapContextCreateImage(context)
        UIGraphicsEndImageContext();
        let texture = try! GLKTextureLoader.textureWithCGImage(image!, options: nil)
        self.scoreTexture = texture;
    }
    
    func cleanMemoryBeforeStartNew() {
        var name: GLuint = (self.scoreTexture?.name)!
        glDeleteTextures(1, &name)
    }
}
