//
//  MusicPlayerViewController.h
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLMusicPlayer.h"

@interface MusicPlayerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CLMusicPlayerProtocol>


@property (strong, nonatomic) IBOutlet UITableView *tableView;

// 播放控制
@property (strong, nonatomic) IBOutlet UIButton *playerButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIButton *lastButton;

@property (strong, nonatomic) IBOutlet UILabel *currentTime;
@property (strong, nonatomic) IBOutlet UILabel *totalTime;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;// MAX TRACK设为透明

@property (nonatomic, strong) CLMusicPlayer *musicPlayer;
@property (nonatomic, strong, readwrite) CLMusicModel *musicModel;

- (instancetype)initWithMusicModel:(CLMusicModel *)musicModel;

@end

/// 消息列表
@interface MusicPlayerCell : UITableViewCell

@property (nonatomic, retain) UILabel *lyricLabel;

@end
