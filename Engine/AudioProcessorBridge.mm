//
//  AudioProcessorBridge.mm
//  VideoFactory
//
//  Created by Jie Chen on 2025/2/5.
//

#import "Foundation/Foundation.h"

#import "AudioProcessorBridge.h"

#include "audio-processor/ffmpeg_processor_impl.hpp"

using namespace donde_toolkits::audio_process;

@implementation AudioProcessorBridge

FFmpegAudioProcessorImpl *impl;


- (void) extractAudioFromVideo:(NSString *) videoFilepath output: (NSString *) audioFilepath {
    NSLog(@"in AudioProcessorBridge.mm, extractAudioFromVideo, video: %@, audio output: %@",
           videoFilepath, audioFilepath);
}

@end
