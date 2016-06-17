//
//  Int32+Extension.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/16/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import GLKit

extension Int32 {
    func __conversion() -> GLenum {
        return GLuint(self)
    }
    
    func __conversion() -> GLboolean {
        return GLboolean(UInt8(self))
    }
    
    func __conversion() -> GLsizei {
        return GLsizei(self)
    }
}

extension Int {
    func __conversion() -> Int32 {
        return Int32(self)
    }
    
    func __conversion() -> GLubyte {
        return GLubyte(self)
    }
}

extension Float {
    public var g: CGFloat {
        return CGFloat(self)
    }
    public var d: Double {
        return Double(self)
    }
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random:Float {
        get {
            return Float(arc4random()) / 0xFFFFFFFF
        }
    }
    /**
     Create a random num Float
     
     - parameter min: Float
     - parameter max: Float
     
     - returns: Float
     */
    public static func random(min min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}

extension CGFloat {
    public var f: Float {
        return Float(self)
    }
}

public enum Uniform {
    case ModelViewProjectionMatrix, NormalMatrix
}

public var gUniforms: [Uniform: GLint] = [:]

extension GLKMatrix3 {
    var array: [Float] {
        return (0..<9).map { i in
            self[i]
        }
    }
}

extension GLKMatrix4 {
    var array: [Float] {
        return (0..<16).map { i in
            self[i]
        }
    }
}

extension Array {
    var bufferSize: size_t {
        return sizeof(Element) * self.count
    }
}

extension Array where Element: Equatable {
    func arrayRemovingObject(object: Element) -> [Element] {
        return filter { $0 != object }
    }
}