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

void setupScreen();

void renderBlockWithStepUpdate(float update, InputData inputData);
void updateLifeCycle(float timeEclapsed);

#endif /* player_h */
