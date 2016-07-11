//
//  shader_processor.h
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#ifndef shader_processor_h
#define shader_processor_h

#include <stdio.h>
#include <OpenGLES/ES2/gl.h>

GLuint load_png_asset_into_texture(const char* relative_path);
GLuint build_program_from_assets(const char* vertex_shader_path, const char* fragment_shader_path);

#endif /* shader_processor_h */
