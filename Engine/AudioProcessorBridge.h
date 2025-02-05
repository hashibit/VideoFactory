//
//  AudioProcessorBridge.h
//  VideoFactory
//
//  Created by Jie Chen on 2025/2/5.
//

@interface AudioProcessorBridge : NSObject

- (void) extractAudioFromVideo: (NSString *) videoFilepath output: (NSString *) audioFilepath;

@end
