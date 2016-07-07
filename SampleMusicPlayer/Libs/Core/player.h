//
//  player.h
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#ifndef player_h
#define player_h

#include <stdio.h>
#include "block_objects.h"
#include <OpenGLES/ES2/gl.h>

static const int MAX_NUM_COLUMN = 6;

void setupScreen();
void on_surface_changed(int width, int height);



void renderBarObject(InputData inputData);
void updateLifeCycle(float timeEclapsed);

//Private
InputData updateInputData(InputData data);
InputData updatePositionStored(InputData data);

void renderBlocks();
void renderBlockWithStepUpdate(InputData inputData);
void updateBlocks();
void updateBlockAtIndex(int index);
void initialData(InputData listDatas[MAX_NUM_COLUMN]);

#endif /* player_h */
