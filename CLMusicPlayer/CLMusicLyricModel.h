//
//  CLMusicLyricModel.h
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CLMusicLyricModel : NSObject

/**
 歌词的开始时间
 */
@property (nonatomic, assign) NSTimeInterval beginTime;

/**
 歌词的内容
 */
@property (nonatomic, copy) NSString* content;

/**
 生成锁屏歌词图片
 
 @param lyrics 歌词数组
 @param currentIndex 当前歌词
 @param backgroundImage 背景图片，歌曲插图
 @return 图片
 */
+ (UIImage *)lockScreenImageWithLyrics:(NSArray *)lyrics
                          currentIndex:(NSInteger)currentIndex
                       backgroundImage:(UIImage *)backgroundImage;

+ (NSArray *)lyrics:(NSString *)lyric;

@end
