//
//  BandsView.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/6/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import OpenGLES
import GLKit

/// For disaplay brands view with OpenGL random brand name
class BrandsView: GLKView {
    var scoreTexture: GLKTextureInfo?
    
    override init(frame: CGRect) {
       super.init(frame: frame)
        drawsimpleBand()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
