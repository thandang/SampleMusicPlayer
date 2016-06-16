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
    var a_pID: UInt32?
    var a_pRadiusOffset: UInt32?
    var a_pVelocityOffset: UInt32?
    var a_pDecayOffset: UInt32?
    var a_pColorOffset: UInt32?
    var a_pSizeOffset: UInt32?
    
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
    
    func loadShader() {
        let pathVS = NSBundle.mainBundle().pathForResource("Block", ofType: "vsh")
        guard let path1 = pathVS else {
            return
        }
        let stringVS = try! String(contentsOfFile: path1)
        let blockVSString = stringVS.cStringUsingEncoding(NSASCIIStringEncoding)
        let blockVS = Utils.ptr(blockVSString!)
        
        let pathFS = NSBundle.mainBundle().pathForResource("Block", ofType: "fsh")
        guard let path2 = pathFS else {
            return
        }
        let stringFS = try! String(contentsOfFile: path2)
        let blockFSString = stringFS.cStringUsingEncoding(NSASCIIStringEncoding)
        let BlockFS = Utils.ptr(blockFSString!)
        
        program = ShaderProcessor().buildProgram(blockVS, fragmentShaderSource: BlockFS)
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
    }
}