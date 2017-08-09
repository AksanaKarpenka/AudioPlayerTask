//
//  AKSAudioPlayerModel.h
//  AKSAudioPlayer
//
//  Created by HomeStation on 8/9/17.
//  Copyright © 2017 AKS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AKSAudioPlayerModel : NSObject

@property (nonatomic, copy, readonly) NSArray *songsList;

+ (NSInteger)currentSongIndex;
+ (void)setCurrentSongIndex:(NSInteger)songIndex;
+ (void)decreaseCurrentSongIndex;
+ (void)increaseCurrentSongIndex;

- (NSArray *)songsList;
- (NSString *)formattedTimeForValue:(NSTimeInterval)timeInterval;
- (NSString *)songName;
- (void)setProperties;

@end
