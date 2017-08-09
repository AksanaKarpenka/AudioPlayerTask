//
//  AKSAudioPlayerModel.m
//  AKSAudioPlayer
//
//  Created by HomeStation on 8/9/17.
//  Copyright © 2017 AKS. All rights reserved.
//

#import "AKSAudioPlayerModel.h"

@interface AKSAudioPlayerModel ()

@property (nonatomic, copy, readwrite) NSArray *songsList;

@end

@implementation AKSAudioPlayerModel

static NSInteger currentSongIndex;

#pragma mark - Class methods

+ (NSInteger)currentSongIndex {
    return currentSongIndex;
}

+ (void)setCurrentSongIndex:(NSInteger)songIndex {
    currentSongIndex = songIndex;
}

+ (void)decreaseCurrentSongIndex {
    currentSongIndex--;
}

+ (void)increaseCurrentSongIndex {
    currentSongIndex++;
}

#pragma mark - object methods

- (void)setProperties {
    currentSongIndex = 0;
    _songsList = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"mp3" subdirectory:nil];
}

- (NSArray *)songsList {
    return _songsList;
}

- (NSString *)formattedTimeForValue:(NSTimeInterval)timeInterval {
    float minutes = floor(timeInterval / 60);
    float seconds = floor(timeInterval) - minutes * 60;
    
    return [NSString stringWithFormat:@"%02.f:%02.f", minutes, seconds];
}

- (NSString *)songName {
    NSString *filename = [self.songsList[currentSongIndex] lastPathComponent];
    return [filename substringToIndex:[filename length] - 4];
}

@end
