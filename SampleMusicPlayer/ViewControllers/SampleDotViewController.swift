//
//  SampleDotViewController.swift
//  SampleMusicPlayer
//
//  Created by Than Dang on 6/17/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

import Foundation
import OpenGLES
import GLKit

class SampleDotViewController: GLKViewController {
    
    var blocks: [BlockObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up context
        let context = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(context)
        let currentView = view as! GLKView
        currentView.context = context
        
        let glPoint = CGPointMake(100.0/view.frame.size.width, 100.0/view.frame.size.height);
        let x = (glPoint.x * 2.0) - 1.0;
        let aspectRatio = view.frame.size.width / view.frame.size.height;
        let y = ((glPoint.y * 2.0) - 1.0) * (-1.0/aspectRatio);
        let block = BlockObject(texture: "block_64.png", position: GLKVector2Make(x.f, y.f))
        
        blocks.append(block)

    }
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        // Set the background color
        glClearColor(0.53, 0.81, 0.92, 1.00);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        
        // Set the blending function (normal w/ premultiplied alpha)
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        
        // Create Projection Matrix
        let aspectRatio = view.frame.size.width / view.frame.size.height;
        let projectionMatrix = GLKMatrix4MakeScale(1.0, aspectRatio.f, 1.0);
        
        // Render Emitters
        if blocks.count > 0 {
            for bl in blocks {
                bl.renderWithProjection(projectionMatrix)
            }
        }
    }
    
    func update() {
        if blocks.count > 0 {
            for bl in blocks {
                let aLive = bl.updateLifeCycle(Float(timeSinceLastUpdate))
                if !aLive {
                    blocks.arrayRemovingObject(bl)
                }
            }
        }
    }
}
