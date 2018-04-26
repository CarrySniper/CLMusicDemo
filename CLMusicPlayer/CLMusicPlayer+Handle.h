//
//  CLMusicPlayer+Handle.h
//  CLMusicDemo
//
//  Created by CJQ on 2018/4/26.
//  Copyright © 2018年 CJQ. All rights reserved.
//

#import "CLMusicPlayer.h"

@interface CLMusicPlayer (Handle)

/**
 添加远程控制中心，用在锁屏和控制中心
 
 @param target 目标对象
 @param playAction 播放动作
 @param pauseAction 暂停动作
 @param lastAction 上一首音乐
 @param nextAction 下一首音乐
 */
- (void)addRemoteCommandCenterWithTarget:(id)target
                              playAction:(SEL)playAction
                             pauseAction:(SEL)pauseAction
                          lastSongAction:(SEL)lastAction
                          nextSongAction:(SEL)nextAction;

/**
 更新锁屏和控制中心画面
 */
- (void)updateLockScreen;

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
