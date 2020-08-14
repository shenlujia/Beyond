//
//  SSAudioEncoder.m
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#define ENABLE_MP3 0

#if ENABLE_MP3
#import <lame/lame.h>
#endif

#import "SSAudioEncoder.h"
#import "SSAudioUtility.h"


@implementation SSAudioEncoder

- (instancetype)init
{
    self = [super init];
    self.sampleRate = 44100;
    return self;
}

- (BOOL)convertPCM:(NSString *)PCMPath toMP3:(NSString *)MP3Path error:(NSError **)error
{
#if ENABLE_MP3
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL readable = [fileManager isReadableFileAtPath:PCMPath];
    if (!readable) {
        [SSAudioUtility resetError:error exception:nil info:@"PCMPath not readable"];
        return NO;
    }
    
    NSString *MP3Directory = [MP3Path stringByDeletingLastPathComponent];
    BOOL writable = [fileManager isWritableFileAtPath:MP3Directory];
    if (!writable) {
        [SSAudioUtility resetError:error exception:nil info:@"MP3Path not writable"];
        return NO;
    }
    
    @try {
        size_t read;
        int write;
        
        FILE *pcm = fopen([PCMPath cStringUsingEncoding:NSUTF8StringEncoding], "rb");
        fseek(pcm, 4 * 1024, SEEK_CUR);
        FILE *mp3 = fopen([MP3Path cStringUsingEncoding:NSUTF8StringEncoding], "wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, self.sampleRate);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, (int)read, mp3_buffer, MP3_SIZE);
            }
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        [SSAudioUtility resetError:error exception:exception info:nil];
        return NO;
    }
    return YES;
#else
    return NO;
#endif
}

@end
