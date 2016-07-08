//
//  block_objects.h
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#ifndef block_objects_h
#define block_objects_h

#include <stdio.h>
#include "program.h"
#include "linmath.h"
#include <OpenGLES/ES2/gl.h>


typedef struct {
    GLuint texture;
    GLuint buffer;
} PointData;


typedef struct {
    float pSizeOffset;
    float pPositionOffset;
} Particles;


typedef struct {
    float positionX;
    float positionY;
    float sizeStart;
    float sizeEnd;
    float delta;
    int   isDown; // 1 is true and 0 is false
    float delta2;
    float currentPositionY;
    float secondPostionY;
    int   numberOfStepItem;
    float nextPosition;
} InputData;

typedef struct {
    Particles  particles[1];
    InputData itemData;
} Block;

typedef struct {
    Particles particles[8]; //TODO: we should synchronize with NUM_POINTS 
    InputData itemData;
}Bar;

typedef struct {
    vec4 color;
    GLuint buffer;
    int num_points;
} ListPointData;


PointData generatePointData(GLuint texture, Block blockData);
PointData generateBarPointData(GLuint texture, Bar barData);

void renderBlockCover(const PointData *data, const TextureProgram *texture_program, mat4x4 m, const InputData inputData);

void renderBar(const PointData *data, const TextureProgram *textureProgram, mat4x4 m, const InputData inputData);

void renderBottomBar(const PointData *data, const TextureProgram *textureProgram, mat4x4 m, const InputData inputData, float plus);

#endif /* block_objects_h */
