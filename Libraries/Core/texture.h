//
//  texture.h
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#ifndef texture_h
#define texture_h

#include <stdio.h>
#include <OpenGLES/ES2/gl.h>
GLuint load_texture(
                    const GLsizei width, const GLsizei height,
                    const GLenum type, const GLvoid* pixels);

#endif /* texture_h */
