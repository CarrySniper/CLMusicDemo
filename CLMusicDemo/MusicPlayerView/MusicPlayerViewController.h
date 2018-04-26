//
//  MusicPlayerViewController.h
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

/*
 UI界面和播放器无关，可以自定义播放器界面。
 但是控制播放器（播放／暂停／改变播放时间）是在这里操作。
 还有上一首／下一首／播放模式／歌词展示／歌曲列表也都在这里展示，需要自己去抽取需要的功能。
 */

#import <UIKit/UIKit.h>
#import "CLMusicPlayer+Handle.h"


typedef NS_ENUM(NSUInteger, CLMusicPlayMode) {
    CLMusicPlayMode_Nomal = 0,        //顺序播放（列表顺序，播放完毕停止）
    CLMusicPlayMode_SingleReplay,     //单曲循环
    CLMusicPlayMode_ListReplay,       //列表循环
    CLMusicPlayMode_RandomPlay,       //随机播放
};

@interface MusicPlayerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CLMusicPlayerDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tableView;

// 播放控制
@property (strong, nonatomic) IBOutlet UIButton *playerButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIButton *lastButton;

@property (strong, nonatomic) IBOutlet UIButton *modeButton;
@property (strong, nonatomic) IBOutlet UIButton *listButton;

@property (strong, nonatomic) IBOutlet UILabel *currentTime;
@property (strong, nonatomic) IBOutlet UILabel *totalTime;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;// MAX TRACK设为透明

// 数据
@property (nonatomic, strong, readwrite) NSArray *defaultMusics;// 全部音乐
@property (nonatomic, strong, readwrite) NSArray *currentMusics;// 当前播放列表（顺序修改过的）

@property (nonatomic, assign) CLMusicPlayMode musicPlayMode;
@property (nonatomic, strong) CLMusicPlayer *musicPlayer;

- (instancetype)initWithMusicModel:(CLMusicModel *)currentMusicModel
                        withMusics:(NSArray *)defaultMusics;

@end

/// 消息列表
@interface MusicPlayerCell : UITableViewCell

@property (nonatomic, retain) UILabel *lyricLabel;

@end
