//
//  BarShader.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/21/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation

class BarShader: NSObject {
    //Program handle
    var program: GLuint?
    
    var a_pSizeOffset: GLint?
    
    var a_pPositionYOffset: GLint?
    
    
    //Uniform handle
    var u_ProjectionMatrix: Int32?
    var u_ePosition: GLint?
    var u_eSizeStart: GLint?
    var u_eSizeEnd: GLint?
    var u_Texture: GLint?
    var u_eDelta: GLint?
    
    var u_eColor: Int32?
    
    
    func loadShader() {
        let pathVS = NSBundle.mainBundle().pathForResource("Bar", ofType: "vsh")
        guard let path1 = pathVS else {
            return
        }
        
        let stringVS: NSString = try! NSString(contentsOfFile: path1, encoding: NSUTF8StringEncoding)
        
        let blockVS = stringVS.UTF8String
        let stringVSLength = GLint(Int32(stringVS.length))
        
        let pathFS = NSBundle.mainBundle().pathForResource("Bar", ofType: "fsh")
        guard let path2 = pathFS else {
            return
        }
        
        let stringFS: NSString = try! NSString(contentsOfFile: path2, encoding: NSUTF8StringEncoding)
        let blockFS = stringFS.UTF8String
        let stringFSLength = GLint(Int32(stringFS.length))
        
        program = ShaderProcessor().buildProgram(blockVS, length1: stringVSLength, fragmentShaderSource: blockFS, length2: stringFSLength)
        guard let program_ = program else {
            return
        }
        
        
        a_pPositionYOffset = glGetAttribLocation(program_, "a_pPositionYOffset")
        
        u_ProjectionMatrix = glGetUniformLocation(program_, "u_ProjectionMatrix")
        
        a_pSizeOffset = glGetAttribLocation(program_, "a_pSizeOffset")
        
        u_ePosition = glGetUniformLocation(program_, "u_ePosition")
        
        u_eSizeStart = glGetUniformLocation(program_, "u_eSizeStart")
        u_eSizeEnd = glGetUniformLocation(program_, "u_eSizeEnd")
        u_Texture = glGetUniformLocation(program_, "u_Texture")
        u_eDelta = glGetUniformLocation(program_, "u_eDelta")
    }
}
