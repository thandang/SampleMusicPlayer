//
//  buffer.h
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#ifndef buffer_h
#define buffer_h

#include <stdio.h>
#include <OpenGLES/ES2/gl.h>

#define BUFFER_OFFSET(i) ((void*)(i))

GLuint create_vbo(const GLsizeiptr size, const GLvoid* data, const GLenum usage);

#endif /* buffer_h */
