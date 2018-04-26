//
//  CLMusicPlayer.h
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "CLMusicModel.h"
#import "CLMusicLyricModel.h"

typedef NS_ENUM(NSInteger, CLMusicStatus) {
    CLMusicStatusNormal,
    CLMusicStatusReadyToPlay,
    CLMusicStatusPlaying,
    CLMusicStatusPause,
    CLMusicStatusFinish
};

#pragma mark -
#pragma mark 协议代理
@class CLMusicPlayer;
@protocol  CLMusicPlayerDelegate<NSObject>
@optional

/**
 音乐切换回调
 */
- (void)cl_musicPlayerReplaceMusic:(CLMusicModel *)musicModel;

/**
 音乐播放状态回调
 */
- (void)cl_musicPlayerStatusChange:(CLMusicStatus)musicStatus;

/**
 音乐缓存进度
 */
- (void)cl_musicPlayerCacheProgress:(float)progress;

/**
 音乐播放进度
 */
- (void)cl_musicPlayerPlayingProgress:(float)progress;

/**
 音乐播放结束
 */
- (void)cl_musicPlayerEndPlay;

/**
 音乐歌词当前下标
 */
- (void)cl_musicPlayerLyricIndex:(NSInteger)lyricIndex;

@end
//==============================

@interface CLMusicPlayer : NSObject

#pragma mark -
#pragma mark 声明属性变量

/** 当前播放的音乐Model */
@property (nonatomic, strong, readonly) CLMusicModel *musicModel;

/** 歌词的数组 */
@property (nonatomic, strong) NSMutableArray *lyricArray;

/** 当前时间 */
@property (nonatomic, assign) NSTimeInterval currentTime;

/** 总时间 */
@property (nonatomic, assign) NSTimeInterval durationTime;

/** 当前播放的歌词的索引 */
@property (nonatomic, assign) NSInteger currectLyricIndex;

/** 音乐播放状态 */
@property (nonatomic, assign) CLMusicStatus status;

/** 协议代理 */
@property (nonatomic, weak) id<CLMusicPlayerDelegate> delegate;


#pragma mark - 
#pragma mark 声明方法函数
/** 实例化 */
+ (instancetype)sharedInstance;

/**
 播放音乐

 @param musicModel 音乐模型
 */
- (void)playMusic:(CLMusicModel *)musicModel;

/**
 播放 / 暂停
 */
- (void)musicPlayOrPause;

/**
 停止
 */
- (void)musicStop;

/**
 跳转音乐进度 —— 开始
 */
- (void)seekToTimeBegin;

/**
 跳转音乐进度 —— 结束

 @param progress 进度（0.0 ~ 1.0）
 @param completionHandler 跳转完成回调
 */
- (void)seekToTimeEndWithProgress:(CGFloat)progress
                   completionHandler:(void (^)(void))completionHandler;


@end
