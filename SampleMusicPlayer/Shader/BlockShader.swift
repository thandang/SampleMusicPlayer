//
//  BlockShader.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/16/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation


class BlockShader: NSObject {
    
    //Program handle
    var program: GLuint?
    
    //Attribute hanlde
    var a_pID: Int32?
    var a_pRadiusOffset: Int32?
    var a_pVelocityOffset: Int32?
    var a_pDecayOffset: Int32?
    var a_pColorOffset: Int32?
    var a_pSizeOffset: Int32?
    
    //Uniform handle
    var u_ProjectionMatrix: Int32?
    var u_Gravity: GLint?
    var u_Time: GLint?
    var u_ePosition: GLint?
    var u_eRadius: GLint?
    var u_eVelocity: GLint?
    var u_eDecay: GLint?
    var u_eSizeStart: GLint?
    var u_eSizeEnd: GLint?
    var u_Texture: GLint?
    var u_eDelta: GLint?
    
    func loadShader() {
        let pathVS = NSBundle.mainBundle().pathForResource("Block", ofType: "vsh")
        guard let path1 = pathVS else {
            return
        }
       
        let stringVS: NSString = try! NSString(contentsOfFile: path1, encoding: NSUTF8StringEncoding)
        
        let blockVS = stringVS.UTF8String
        let stringVSLength = GLint(Int32(stringVS.length))
        
        let pathFS = NSBundle.mainBundle().pathForResource("Block", ofType: "fsh")
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
        
        a_pID = glGetAttribLocation(program_, "a_pID")
        a_pRadiusOffset = glGetAttribLocation(program_, "a_pRadiusOffset")
        a_pVelocityOffset = glGetAttribLocation(program_, "a_pVelocityOffset")
        a_pDecayOffset = glGetAttribLocation(program_, "a_pDecayOffset")
        a_pColorOffset = glGetAttribLocation(program_, "a_pColorOffset")
        a_pSizeOffset = glGetAttribLocation(program_, "a_pSizeOffset")
        
        u_ProjectionMatrix = glGetUniformLocation(program_, "u_ProjectionMatrix")
        u_Gravity = glGetUniformLocation(program_, "u_Gravity")
        u_Time = glGetUniformLocation(program_, "u_Time")
        u_ePosition = glGetUniformLocation(program_, "u_ePosition")
        u_eRadius = glGetUniformLocation(program_, "u_eRadius")
        u_eVelocity = glGetUniformLocation(program_, "u_eVelocity")
        u_eDecay = glGetUniformLocation(program_, "u_eDecay")
        u_eSizeStart = glGetUniformLocation(program_, "u_eSizeStart")
        u_eSizeEnd = glGetUniformLocation(program_, "u_eSizeEnd")
        u_Texture = glGetUniformLocation(program_, "u_Texture")
        u_eDelta = glGetUniformLocation(program_, "u_eDelta")
    }
}