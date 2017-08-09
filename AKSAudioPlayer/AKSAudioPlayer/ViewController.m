//
//  ViewController.m
//  AKSAudioPlayer
//
//  Created by HomeStation on 8/8/17.
//  Copyright © 2017 AKS. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, copy) NSArray *songsList;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

static NSInteger currentSongIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.songsList = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"mp3" subdirectory:nil];
    
    currentSongIndex = 0;
    
    [self configAudioPlayer:currentSongIndex];
    
    [self showCurrentlySelectedSongName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showCurrentlySelectedSongName {
    NSString *filename = [self.songsList[currentSongIndex] lastPathComponent];
    self.currentMusicSongLabel.text = [filename substringToIndex:[filename length] - 4];
}

- (void)prepareSongPlaying {
    [self configAudioPlayer:currentSongIndex];
    [self.audioPlayer play];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(fireTimeInterval)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self fireTimeInterval];
    self.playPauseButton.selected = YES;
    
    [self.musicSongsTable reloadData];
    
    [self showCurrentlySelectedSongName];
}

- (NSString *)formattedTimeForValue:(NSTimeInterval)timeInterval {
    float minutes = floor(timeInterval / 60);
    float seconds = floor(timeInterval) - minutes * 60;
    
    return [NSString stringWithFormat:@"%02.f:%02.f", minutes, seconds];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.timer invalidate];
    currentSongIndex = indexPath.row;
    [self prepareSongPlaying];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.songsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"musicSongCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSString *filename = [self.songsList[indexPath.row] lastPathComponent];
    
    cell.textLabel.text = [filename substringToIndex:[filename length] - 4];
    
    if (indexPath.row == currentSongIndex) {
        cell.backgroundColor = [UIColor colorWithRed:(94 / 255.0) green:(112 /255.0) blue:(141 / 255.0) alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:(102 / 255.0) green:(255 /255.0) blue:(204 / 255.0) alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:(163 / 255.0) green:(174 /255.0) blue:(190 / 255.0) alpha:1.0];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}


#pragma mark - Audio Player Actions

- (void)configAudioPlayer:(NSInteger)songIndex {
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        self.audioPlayer.delegate = nil;
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.songsList[songIndex] error:nil];
    
    self.audioPlayer.delegate = self;
    
    [self.audioPlayer prepareToPlay];
    
    self.durationLabel.text = [self formattedTimeForValue:self.audioPlayer.duration];
    
    self.musicSoundSlider.minimumValue = 0;
    self.musicSoundSlider.maximumValue = self.audioPlayer.duration;
}

- (IBAction)playButtonTapped:(id)sender {
    [self.timer invalidate];
    
    if ([sender isSelected]) {
        [self.audioPlayer pause];
    } else {
        [self.audioPlayer play];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(fireTimeInterval)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
    [sender setSelected:![sender isSelected]];
}

- (IBAction)musicSoundSliderValueChanged:(UISlider *)sender {
    self.timePassedLabel.text = [self formattedTimeForValue:sender.value];
}

- (IBAction)musicSoundSliderValueSelected:(UISlider *)sender {
    self.audioPlayer.currentTime = sender.value;
    [self fireTimeInterval];
}

- (IBAction)prevButtonTapped:(id)sender {
    [self.timer invalidate];
    currentSongIndex--;
    
    if (currentSongIndex < 0) {
        currentSongIndex = self.songsList.count - 1;
    }
    
    [self prepareSongPlaying];
}

- (IBAction)nextButtonTapped:(UIButton *)sender {
    [self.timer invalidate];
    currentSongIndex++;
    
    if (currentSongIndex >= self.songsList.count) {
        currentSongIndex = 0;
    }
    
    [self prepareSongPlaying];
}

- (void)fireTimeInterval {
    self.timePassedLabel.text = [self formattedTimeForValue:self.audioPlayer.currentTime];
    self.musicSoundSlider.value = self.audioPlayer.currentTime;
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [self.timer invalidate];
    [self.audioPlayer stop];
    
    currentSongIndex++;
    
    if (currentSongIndex >= self.songsList.count) {
        currentSongIndex = 0;
    }
    
    [self prepareSongPlaying];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self.timer invalidate];
    self.playPauseButton.selected = NO;
    self.musicSoundSlider.value = 0;
    self.timePassedLabel.text = @"00:00";
    currentSongIndex = 0;
}

@end
