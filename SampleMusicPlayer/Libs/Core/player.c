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

static const float plusX = 0.014;
static const float bottomYCap = -0.26;
static const float stepBlock = 0.05;
static const float stepBar = 0.1;
static const float pointSizeHeight = 0.04;
static const float distanceBar2Block = 0.05;
static const float MAX_LEVEL = 0.2;
static const float fixedSizeOffset = 0.1;
static const float fixedPositionOffset = 0.5;

float positionStoredY;

GLuint blockTexture;
GLuint barTexture;
GLuint bottomBarTexture;

TextureProgram textureProgram;
TextureProgram textureProgram2;
TextureProgram textureProgram3;

PointData pointData;


static mat4x4 projection_matrix;
static mat4x4 model_matrix;
static mat4x4 view_matrix;

static mat4x4 view_projection_matrix;
static mat4x4 model_view_projection_matrix;
static mat4x4 inverted_view_projection_matrix;


//Private function
static void position_object_in_scene(float x, float y, float z);
static InputData updateInputData(InputData data);
static InputData updatePositionStored(InputData data);
static void renderBlockWithStepUpdate(InputData inputData);
static void renderBarObject(InputData inputData);
static inline float deg_to_radf(float deg) {
    return deg * (float)M_PI / 180.0f;
}

InputData storedInputDatas[MAX_NUM_COLUMN];


#pragma mark - public functions
void setupScreen() {
    glClearColor(0.3f, 0.3f, 0.3f, 1.0);
    
    textureProgram = get_texture_program(build_program_from_assets("Block.vsh", "Block.fsh"));
    textureProgram2 = get_texture_program(build_program_from_assets("Bar.vsh", "Bar.fsh"));
}


void on_surface_changed(int width, int height) {
    glViewport(0, 0, width, height);
    mat4x4_perspective(projection_matrix, deg_to_radf(45), (float) width / (float) height, 10.0f, 10.0f);
    mat4x4_look_at(view_matrix, (vec3){0.0f, 0.0f, 5.0f}, (vec3){0.0f, 0.0f, 0.0f}, (vec3){0.0f, 1.0f, 0.0f});
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

void renderBlocks() {
    for (int i = 0; i < MAX_NUM_COLUMN; i++) {
        InputData item = updatePositionStored(storedInputDatas[i]);
        storedInputDatas[i] = item;
        renderBlockWithStepUpdate(item);
        renderBarObject(item);
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


#pragma mark - Static function
static void renderBlockWithStepUpdate(InputData inputData) {
    mat4x4_mul(view_projection_matrix, projection_matrix, view_matrix);
    mat4x4_invert(inverted_view_projection_matrix, view_projection_matrix);
    position_object_in_scene(0.7f, 0.0f, 0.0f);
    Block block = {{{0.0f, 0.0f}}, inputData};
    pointData = generatePointData(load_png_asset_into_texture("block_64.png"), block);
    renderBlockCover(&pointData, &textureProgram, model_view_projection_matrix, inputData);
}

static void renderBarObject(InputData inputData) {
    float step = stepBlock;
    float nextPosition = BOTTOM_Y;
    for (int i = inputData.numberOfStepItem; i >= 0; i--) {
        nextPosition = BOTTOM_Y + 0.02 + step * i;
        if (nextPosition > inputData.secondPostionY) {
            nextPosition = inputData.secondPostionY;
        }
        if (nextPosition + inputData.delta2 < BOTTOM_Y) {
            break;
        }
        inputData.nextPosition = nextPosition;
        
        Bar bar = {{{fixedSizeOffset, fixedPositionOffset}, {fixedSizeOffset, fixedPositionOffset}, {fixedSizeOffset, fixedPositionOffset}, {fixedSizeOffset, fixedPositionOffset}, {fixedSizeOffset, fixedPositionOffset}, {fixedSizeOffset, fixedPositionOffset}, {fixedSizeOffset, fixedPositionOffset}, {fixedSizeOffset, fixedPositionOffset}}, inputData};
        PointData data = generateBarPointData(load_png_asset_into_texture("bar_64.png"), bar);
        renderBar(&data, &textureProgram2, model_view_projection_matrix, inputData);
    }
    
    Bar bottomBar = {{0.05, 0.5}, inputData};
    PointData dataBottom = generateBarPointData(load_png_asset_into_texture("bar_32.png"), bottomBar);
    renderBottomBar(&dataBottom, &textureProgram2, model_view_projection_matrix, inputData, plusX);
    
    renderBottomBar(&dataBottom, &textureProgram2, model_view_projection_matrix, inputData, -plusX);
}
static InputData updatePositionStored(InputData data) {
    InputData inputData = data;
    if (inputData.positionY + inputData.delta < bottomYCap) { //Limit the bottom position for tear down
        inputData.positionY = bottomYCap;
        inputData.delta = 0.0;
    }
    return inputData;
}

static InputData updateInputData(InputData data) {
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
