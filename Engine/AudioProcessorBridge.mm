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

- (instancetype) init {
    self = [super init];
    if (self) {
        impl = new FFmpegAudioProcessorImpl();
    }
    return self;
}

- (void) dealloc {
    if (impl) {
        delete impl;
        impl = nullptr;
    }
}

- (void) extractAudioFromVideo:(NSString *) videoFilepath output: (NSString *) audioFilepath {
    AudioStreamInfo info = impl->OpenContext([videoFilepath cStringUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"audio stream info: %d", info.open_success);
    NSLog(@"in AudioProcessorBridge.mm, extractAudioFromVideo, video: %@, audio output: %@",
           videoFilepath, audioFilepath);
    impl->Transcode([audioFilepath cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
