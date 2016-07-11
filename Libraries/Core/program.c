//
//  program.c
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#include "program.h"
//We actually need a program for texture
//And calculate them as velocity changed
TextureProgram get_texture_program(GLuint program) {
    return (TextureProgram) {
        program,
        
        glGetUniformLocation(program, "u_ProjectionMatrix"),
        glGetAttribLocation(program, "a_pSizeOffset"),
        glGetUniformLocation(program, "u_ePosition"),
        glGetUniformLocation(program, "u_eSizeStart"),
        glGetUniformLocation(program, "u_eSizeEnd"),
        glGetUniformLocation(program, "u_Texture"),
        glGetUniformLocation(program, "u_eDelta")};
}

ColorProgram get_color_program(GLuint program) {
    return (ColorProgram) {
        program,
        glGetAttribLocation(program, "a_Position"),
        glGetUniformLocation(program, "u_MvpMatrix"),
        glGetUniformLocation(program, "u_Color")};
}