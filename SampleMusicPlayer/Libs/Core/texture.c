//
//  texture.c
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#include "texture.h"
#include <assert.h>

/**
 *  load texture from png file image
 *
 *  @param width  texture width
 *  @param height texture height
 *  @param type   get image color type. We set default as GL_RGBA
 *  @param pixels pixels data
 *
 *  @return GLuint
 */
GLuint load_texture(
                    const GLsizei width, const GLsizei height,
                    const GLenum type, const GLvoid* pixels) {
    GLuint texName;
    glGenTextures(1, &texName);
    assert(texName != 0);
    
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, type, width, height, 0, type, GL_UNSIGNED_BYTE, pixels);
    
    glBindTexture(GL_TEXTURE_2D, 0); //Free up data
    
    return texName;
}
