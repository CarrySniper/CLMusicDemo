//
//  CLMusicModel.h
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YYModel.h>

@interface CLMusicModel : NSObject

/** 歌名 */
@property (nonatomic, copy) NSString *songName;

/** 歌手名 */
@property (nonatomic, copy) NSString *singerName;

/** 专辑 */
@property (nonatomic, copy) NSString *album;

/** 链接 */
@property (nonatomic, copy) NSString *songLink;

/** 歌词数组 */
@property (nonatomic, copy) NSArray *lyrics;

/** 歌曲插图 */
@property (nonatomic, copy) NSString *thumb;
@property (nonatomic, copy) UIImage *thumbImage;


@end
