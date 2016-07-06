//
//  platform_asset_utils.m
//  SampleMusicPlayer
//
//  Created by Than Dang on 7/5/16.
//  Copyright © 2016 Than Dang. All rights reserved.
//

#include <stdio.h>
#include "platform_asset_utils.h"
#include "platform_file_utils.h"
#include <assert.h>
#include <stdlib.h>
#import <UIKit/UIKit.h>


FileData get_asset_data(const char* relative_path) {
    assert(relative_path != NULL);
    
    NSString *pathString = [[NSString alloc] initWithCString:relative_path encoding:NSASCIIStringEncoding];

    return get_file_data([[[NSBundle mainBundle] pathForResource:pathString ofType:nil] cStringUsingEncoding:NSASCIIStringEncoding]);
}

void release_asset_data(const FileData* file_data) {
    assert(file_data != NULL);
    release_file_data(file_data);
}