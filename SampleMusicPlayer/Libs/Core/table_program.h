//
//  table_program.h
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/7/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#ifndef table_program_h
#define table_program_h

#include <stdio.h>
#include <OpenGLES/ES2/gl.h>

typedef struct {
    GLuint program;
    
    GLint a_position_location;
    GLint a_texture_coordinates_location;
    GLint u_mvp_matrix_location;
    GLint u_texture_unit_location;
} TableTextureProgram;

TableTextureProgram get_table_texture_program(GLuint program);

#endif /* table_program_h */
