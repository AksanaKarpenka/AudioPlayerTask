//
//  ViewController.h
//  AKSAudioPlayer
//
//  Created by HomeStation on 8/8/17.
//  Copyright © 2017 AKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *musicSongsTable;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timePassedLabel;
@property (weak, nonatomic) IBOutlet UISlider *musicSoundSlider;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *currentMusicSongLabel;

- (IBAction)playButtonTapped:(id)sender;
- (IBAction)musicSoundSliderValueChanged:(UISlider *)sender;
- (IBAction)musicSoundSliderValueSelected:(UISlider *)sender;
- (IBAction)prevButtonTapped:(UIButton *)sender;
- (IBAction)nextButtonTapped:(UIButton *)sender;

@end
