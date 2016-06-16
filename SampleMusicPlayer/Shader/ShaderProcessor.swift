//
//  ShaderProcessor.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/16/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation

class ShaderProcessor: NSObject {
//    func buildProgram(vertexShaderSource: UnsafePointer<UnsafePointer<GLchar>>, fragmentShaderSource: UnsafePointer<UnsafePointer<GLchar>>) -> GLuint {
    func buildProgram(vertexShaderSource: UnsafePointer<GLchar>?, length1: GLint, fragmentShaderSource: UnsafePointer<GLchar>?, length2: GLint) -> GLuint {
        let vertexShader = buildShader(vertexShaderSource, shaderType: GLenum(GL_VERTEX_SHADER), length: length1)
        let fragmentShader = buildShader(fragmentShaderSource, shaderType: GLenum(GL_FRAGMENT_SHADER), length: length2)
        let programHandle = glCreateProgram()
        
        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)
        
        glLinkProgram(programHandle)
        
        var linkSuccess: GLint = GLint()
        
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
        if linkSuccess == GL_FALSE {
            print("Failed to create shader program!")
            // TODO: Actually output the error that we can get from the glGetProgramInfoLog function.
            exit(1);
        }
        
        //Delete after completely attach to success program handler
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        return programHandle
    }
    
    func buildShader(source: UnsafePointer<GLchar>?, shaderType: GLenum, length: GLint) -> GLuint {
        let shaderHandle = glCreateShader(shaderType)
        var copySource = source
        var copyLength = length
        glShaderSource(shaderHandle, 1, &copySource!, &copyLength)
        glCompileShader(shaderHandle)
        
        
        
        var compileSuccess: GLint = GLint()
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if compileSuccess == GL_FALSE {
            print("Failed to compile shader!")
            // TODO: Actually output the error that we can get from the glGetShaderInfoLog function.
            exit(1);
        }
        return shaderHandle
    }
}

