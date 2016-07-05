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
    GLuint texture_object_id;
    glGenTextures(1, &texture_object_id);
    assert(texture_object_id != 0);
    
    glBindTexture(GL_TEXTURE_2D, texture_object_id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, type, width, height, 0, type, GL_UNSIGNED_BYTE, pixels);
    
    glBindTexture(GL_TEXTURE_2D, 0); //Free up data
    
    return texture_object_id;
}
