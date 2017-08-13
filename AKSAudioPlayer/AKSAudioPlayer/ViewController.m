//
//  ViewController.m
//  AKSAudioPlayer
//
//  Created by HomeStation on 8/8/17.
//  Copyright © 2017 AKS. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>

@property (nonatomic, strong, readwrite) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong, readwrite) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.model = [[AKSAudioPlayerModel alloc] init];

    [self.model setProperties];
    
    [self configAudioPlayer:[AKSAudioPlayerModel currentSongIndex]];
    
    [self showCurrentlySelectedSongName];
    self.musicSongsTable.backgroundColor = [UIColor colorWithRed:(67 / 255.0) green:(94 /255.0) blue:(135 / 255.0) alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showCurrentlySelectedSongName {
    self.currentMusicSongLabel.text = [self.model songName];
}

- (void)startPlayingSong {
    [self configAudioPlayer:[AKSAudioPlayerModel currentSongIndex]];
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


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.timer invalidate];
    [AKSAudioPlayerModel setCurrentSongIndex:indexPath.row];
    [self startPlayingSong];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.model songsList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"musicSongCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSString *filename = [[self.model songsList][indexPath.row] lastPathComponent];
    
    cell.textLabel.text = [filename substringToIndex:[filename length] - 4];
    
    if (indexPath.row == [AKSAudioPlayerModel currentSongIndex]) {
        cell.backgroundColor = [UIColor colorWithRed:(94 / 255.0) green:(112 /255.0) blue:(141 / 255.0) alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:(102 / 255.0) green:(255 /255.0) blue:(204 / 255.0) alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor colorWithRed:(67 / 255.0) green:(94 /255.0) blue:(135 / 255.0) alpha:1.0];
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
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self.model songsList][songIndex] error:nil];
    
    self.audioPlayer.delegate = self;
    
    [self.audioPlayer prepareToPlay];
    
    self.durationLabel.text = [self.model formattedTimeForValue:self.audioPlayer.duration];
    
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
    [self.timer invalidate];
    self.timePassedLabel.text = [self.model formattedTimeForValue:sender.value];
    self.durationLabel.text = [self.model formattedTimeForValue:(self.audioPlayer.duration - sender.value)];
}

- (IBAction)musicSoundSliderValueSelected:(UISlider *)sender {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(fireTimeInterval)
                                                userInfo:nil
                                                 repeats:YES];
    self.audioPlayer.currentTime = sender.value;
    [self fireTimeInterval];
}

- (IBAction)prevButtonTapped:(id)sender {
    [self.timer invalidate];
    [AKSAudioPlayerModel decreaseCurrentSongIndex];
    
    if ([AKSAudioPlayerModel currentSongIndex] < 0) {
        [AKSAudioPlayerModel setCurrentSongIndex:[[self.model songsList] count] - 1];
    }
    
    [self startPlayingSong];
}

- (IBAction)nextButtonTapped:(UIButton *)sender {
    [self.timer invalidate];
    [AKSAudioPlayerModel increaseCurrentSongIndex];
    
    if ([AKSAudioPlayerModel currentSongIndex] >= [[self.model songsList] count]) {
        [AKSAudioPlayerModel setCurrentSongIndex:0];
    }
    
    [self startPlayingSong];
}

- (void)fireTimeInterval {
    self.timePassedLabel.text = [self.model formattedTimeForValue:self.audioPlayer.currentTime];
    self.durationLabel.text = [self.model formattedTimeForValue:(self.audioPlayer.duration - self.audioPlayer.currentTime)];
    self.musicSoundSlider.value = self.audioPlayer.currentTime;
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.timer invalidate];
    [self.audioPlayer stop];
    
    [AKSAudioPlayerModel increaseCurrentSongIndex];
    
    if ([AKSAudioPlayerModel currentSongIndex] >= [[self.model songsList] count]) {
        [AKSAudioPlayerModel setCurrentSongIndex:0];
    }
    
    [self startPlayingSong];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self.timer invalidate];
    self.playPauseButton.selected = NO;
    self.musicSoundSlider.value = 0;
    self.timePassedLabel.text = @"00:00";
    self.durationLabel.text = @"00:00";
    [AKSAudioPlayerModel setCurrentSongIndex:0];
}

@end
