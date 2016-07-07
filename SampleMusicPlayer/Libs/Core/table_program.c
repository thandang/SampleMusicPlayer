//
//  table_program.c
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/7/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#include "table_program.h"

TableTextureProgram get_table_texture_program(GLuint program) {
    
    return (TableTextureProgram) {
        program,
        glGetAttribLocation(program, "a_Position"),
        glGetAttribLocation(program, "a_TextureCoordinates"),
        glGetUniformLocation(program, "u_MvpMatrix"),
        glGetUniformLocation(program, "u_TextureUnit")};
}