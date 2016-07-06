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

float delta1;
float delta2;

static const float plusX = 0.011;
static const float bottomY = -0.3;
static const float bottomYCap = 0.26;
static const float stepBlock = 0.05;
static const float pointSize = 32.0;
static const float halfPointSize = 18.0;
static const float pointSizeHeight = 0.04;
static const float distanceBar2Block = 0.01;

float positionStoreX;
float positionStoreY;

GLuint blockTexture;
GLuint barTexture;
GLuint bottomBarTexture;


void setupScreen() {
    
}

void renderBlockWithStepUpdate(float update) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
}




void updateLifeCycle(float timeEclapsed) {
    //For update lifeCycle from feedback time
}
