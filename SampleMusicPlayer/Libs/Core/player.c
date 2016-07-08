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
#include "linmath.h"


float delta;
float delta2;
float currentPositionY;
int isDown = 0; // 1 is true and 0 is false
float secondPostionY;
int numberOfStepItem = 5;


//static const float plusX = 0.011;
//static const float bottomY = -0.3;
//static const float halfPointSize = 18.0;
static const float bottomYCap = -0.26;
static const float stepBlock = 0.05;
static const float stepBar = 0.1;
static const float pointSizeHeight = 0.04;
static const float distanceBar2Block = 0.01;
static const float MAX_LEVEL = 0.2;

float positionStoredY;

GLuint blockTexture;
GLuint barTexture;
GLuint bottomBarTexture;

TextureProgram textureProgram;
TextureProgram textureProgram2;

PointData pointData;


static mat4x4 projection_matrix;
static mat4x4 model_matrix;
static mat4x4 view_matrix;

static mat4x4 view_projection_matrix;
static mat4x4 model_view_projection_matrix;
static mat4x4 inverted_view_projection_matrix;


static void position_object_in_scene(float x, float y, float z);

static inline float deg_to_radf(float deg) {
    return deg * (float)M_PI / 180.0f;
}

InputData storedInputDatas[MAX_NUM_COLUMN];

void setupScreen() {
    glClearColor(0.3f, 0.3f, 0.3f, 1.0);
    
    textureProgram = get_texture_program(build_program_from_assets("Block.vsh", "Block.fsh"));
    InputData inputData = {1.0f, 0.3f, 32.0f, 32.0f, 0.1f};
    Block block = {{{0.05f, 0.5f}}, inputData};
    pointData = generatePointData(load_png_asset_into_texture("bar_64.png"), block);
}


void on_surface_changed(int width, int height) {
    glViewport(0, 0, width, height);
    mat4x4_perspective(projection_matrix, deg_to_radf(45), (float) width / (float) height, 1.0f, 10.0f);
    mat4x4_look_at(view_matrix, (vec3){0.0f, 1.2f, 2.2f}, (vec3){0.0f, 0.0f, 0.0f}, (vec3){0.0f, 1.0f, 0.0f});
}

/**
    Init data with six items
 
 - returns: storedInputData to local control here
 */
void initialData(InputData listDatas[MAX_NUM_COLUMN]) {
    for (int i = 0; i < MAX_NUM_COLUMN; i++) {
        storedInputDatas[i] = listDatas[i];
    }
}

void renderBlockWithStepUpdate(InputData inputData) {
    mat4x4_mul(view_projection_matrix, projection_matrix, view_matrix);
    mat4x4_invert(inverted_view_projection_matrix, view_projection_matrix);
    position_object_in_scene(0.0f, 1.0f, 0.0f);
    Block block = {{{0.1f, 0.2f}}, inputData};
    pointData = generatePointData(load_png_asset_into_texture("bar_64.png"), block);
    renderBlockCover(&pointData, &textureProgram, model_view_projection_matrix, inputData);
}


void renderBlocks() {
    for (int i = 0; i < MAX_NUM_COLUMN; i++) {
        InputData item = updatePositionStored(storedInputDatas[i]);
        storedInputDatas[i] = item;
        renderBlockWithStepUpdate(item);
    }
}

/**
 *  Update everytime update function from glkit invoke
 */
void updateBlocks() {
    for (int i = 0; i < MAX_NUM_COLUMN; i++) {
        InputData tmpData = updateInputData(storedInputDatas[i]);
        storedInputDatas[i] = tmpData;
    }
}


/**
 *  Invoke everytime display link catch up
 *
 *  @param index index of data item
 *  @param data  data item contain y value
 */
void updateBlockAtIndex(int index) {
    storedInputDatas[index].isDown = 0;
    storedInputDatas[index].positionY = MAX_LEVEL;
}

void renderBarObject(InputData data) {
    
}



InputData updatePositionStored(InputData data) {
    InputData inputData = data;
    if (inputData.positionY + inputData.delta < bottomYCap) { //Limit the bottom position for tear down
        inputData.positionY = bottomYCap;
        inputData.delta = 0.0;
    }
    return inputData;
}

InputData updateInputData(InputData data) {
    InputData tmp = data;
    //Only update yValue if bar is moving down
    if (tmp.currentPositionY == tmp.positionY) {
        tmp.isDown = 1;
    }

    //We store the current position to calculate state of moving (up or down)
    tmp.currentPositionY = tmp.positionY;
    
    //secondPositionY is used to draw bar, it's a little down of cap position
    tmp.secondPostionY = tmp.positionY - distanceBar2Block;
    
    //Calculate the number of item should we draw a bar
    tmp.numberOfStepItem = tmp.positionY/pointSizeHeight + 8;
    tmp.delta2 -= stepBar;
    
    /* We calculate the velocity for cover
     * Next time we should move the calculate to glsl to make it works on Android too
     */
    if (tmp.isDown == 1) {
        tmp.delta -= stepBlock;
    } else {
        tmp.delta = 0.0;
        tmp.delta2 = 0.0;
    }
    
    return  tmp;
}

static void position_object_in_scene(float x, float y, float z) {
    mat4x4_identity(model_matrix);
    mat4x4_translate_in_place(model_matrix, x, y, z);
    mat4x4_mul(model_view_projection_matrix, view_projection_matrix, model_matrix);
}
