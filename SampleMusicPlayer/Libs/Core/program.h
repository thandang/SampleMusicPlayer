//
//  program.h
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#ifndef program_h
#define program_h

#pragma once
#include <stdio.h>
#include <OpenGLES/ES2/gl.h>

typedef struct {
    GLuint program;
    
    int32_t u_ProjectionMatrix;
    GLint a_pSizeOffset;
    
    GLint u_ePosition;
    GLint u_eSizeStart;
    GLint u_eSizeEnd;
    GLint u_Texture;
    GLint u_eDelta;
} TextureProgram;

typedef struct {
    GLuint program;
    
    GLint a_position_location;
    GLint u_mvp_matrix_location;
    GLint u_color_location;
} ColorProgram;




TextureProgram get_texture_program(GLuint program);
ColorProgram get_color_program(GLuint program);

#endif /* program_h */
