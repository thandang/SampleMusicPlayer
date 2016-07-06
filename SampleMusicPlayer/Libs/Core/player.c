//
//  player.c
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#include "player.h"
#include "shader.h"
#include "buffer.h"
#include "texture.h"
#include "program.h"
#include "shader_processor.h"

float delta1;
float delta2;

//static const float plusX = 0.011;
//static const float bottomY = -0.3;
//static const float bottomYCap = 0.26;
//static const float stepBlock = 0.05;
//static const float pointSize = 32.0;
//static const float halfPointSize = 18.0;
//static const float pointSizeHeight = 0.04;
//static const float distanceBar2Block = 0.01;

static mat4x4 model_view_projection_matrix;

float positionStoreX;
float positionStoreY;

GLuint blockTexture;
GLuint barTexture;
GLuint bottomBarTexture;

TextureProgram textureProgram;
ColorProgram colorProgram;
PointData pointData;
//Block blocksData[];

static mat4x4 projection_matrix;
static mat4x4 model_matrix;
static mat4x4 view_projection_matrix;

static void position_object_in_scene(float x, float y, float z);

void setupScreen() {
    glClearColor(0.3f, 0.3f, 0.3f, 1.0);
    glEnable(GL_DEPTH_TEST);
    
    textureProgram = get_texture_program(build_program_from_assets("Block.vsh", "Block.fsh"));
    InputData inputData = {1.0f, 0.3f, 32.0f, 32.0f, 0.1f};
    Block block = {{{0.1f, 0.1f}, {0.1f, 0.2f}, {0.1f, 0.2f}, {0.1f, 0.2f}, {0.1f, 0.2f}}, inputData};
    pointData = generatePointData(load_png_asset_into_texture("block_64.png"), block);
}

void renderBlockWithStepUpdate(float update, InputData inputData) {
    glClear(GL_COLOR_BUFFER_BIT);
    //must be update block data
    position_object_in_scene(0.3f, 0.5f, 0.0f);
    
    Block block = {{{0.1f, 0.1f}, {0.1f, 0.2f}, {0.1f, 0.2f}, {0.1f, 0.2f}, {0.1f, 0.2f}}, inputData};
    pointData = generatePointData(load_png_asset_into_texture("block_64.png"), block);
    renderBlockCover(&pointData, &textureProgram, projection_matrix, &inputData);
}




void updateLifeCycle(float timeEclapsed) {
    //For update lifeCycle from feedback time
}

static void position_object_in_scene(float x, float y, float z) {
    mat4x4_identity(model_matrix);
    mat4x4_translate_in_place(model_matrix, x, y, z);
    mat4x4_mul(model_view_projection_matrix, view_projection_matrix, model_matrix);
}
