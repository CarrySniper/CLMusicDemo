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
@protocol  CLMusicPlayerProtocol<NSObject>
@optional


/**
 音乐切换回调
 */
- (void)musicPlayerReplaceMusic:(CLMusicModel *)musicModel;

/**
 音乐播放状态回调
 */
- (void)musicPlayerStatusChange:(CLMusicStatus)musicStatus;

/**
 音乐缓存进度
 */
- (void)musicPlayerCacheProgress:(float)progress;

/**
 音乐播放进度
 */
- (void)musicPlayerPlayingProgress:(float)progress;

/**
 音乐播放结束
 */
- (void)musicPlayerEndPlay;

/**
 音乐歌词当前下标
 */
- (void)musicPlayerLyricIndex:(NSInteger)lyricIndex;

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
@property (nonatomic ,assign) id<CLMusicPlayerProtocol> protocol;


#pragma mark - 
#pragma mark 声明方法函数
/** 实例化 */
+ (instancetype)instance;

/**
 播放音乐

 @param musicModel 音乐模型
 */
- (void)cl_playMusic:(CLMusicModel *)musicModel;

/**
 播放 / 暂停
 */
- (void)cl_musicPlayOrPause;

/**
 停止
 */
- (void)cl_musicStop;

/**
 跳转音乐进度 —— 开始
 */
- (void)cl_seekToTimeBegin;

/**
 跳转音乐进度 —— 结束

 @param progress 进度（0.0 ~ 1.0）
 @param completionHandler 跳转完成回调
 */
- (void)cl_seekToTimeEndWithProgress:(CGFloat)progress
                   completionHandler:(void (^)())completionHandler;

/**
 添加远程控制中心，用在锁屏和控制中心

 @param target 目标对象
 @param playAction 播放动作
 @param pauseAction 暂停动作
 @param lastAction 上一首音乐
 @param nextAction 下一首音乐
 */
- (void)cl_addRemoteCommandCenterWithTarget:(id)target
                                 playAction:(SEL)playAction
                                pauseAction:(SEL)pauseAction
                             lastSongAction:(SEL)lastAction
                             nextSongAction:(SEL)nextAction;

/**
 更新锁屏和控制中心画面
 */
- (void)cl_updateLockScreen;

#pragma mark -
#pragma mark 其他辅助方法
/**
 时间格式转换
 
 @param duration 时间秒数
 @return 时间字符串 如 00:00
 */
- (NSString *)cl_formatTime:(NSTimeInterval)duration;

/**
 为数组随机排序

 @param array 源数组
 @return 随机数组
 */
- (NSArray *)cl_randomArray:(NSArray *)array;

@end
