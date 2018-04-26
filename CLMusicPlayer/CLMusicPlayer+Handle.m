//
//  CLMusicPlayer+Handle.m
//  CLMusicDemo
//
//  Created by CJQ on 2018/4/26.
//  Copyright © 2018年 CJQ. All rights reserved.
//

#import "CLMusicPlayer+Handle.h"

@implementation CLMusicPlayer (Handle)

#pragma mark 添加远程控制中心
- (void)addRemoteCommandCenterWithTarget:(id)target
                              playAction:(SEL)playAction
                             pauseAction:(SEL)pauseAction
                          lastSongAction:(SEL)lastAction
                          nextSongAction:(SEL)nextAction {
    // 远程控制类    播放/暂停/上一曲/下一曲
    MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
    [center.playCommand addTarget:target action:playAction];
    [center.pauseCommand addTarget:target action:pauseAction];
    [center.previousTrackCommand addTarget:target action:lastAction];
    [center.nextTrackCommand addTarget:target action:nextAction];
}

#pragma mark 更新锁屏歌词
static NSInteger _index = -1;
- (void)updateLockScreen {
    // MARK 歌词不变或者app前台运行不需要锁屏歌词，但iOS10控制中心在前台也是需要的……
    // [UIApplication sharedApplication].applicationState == UIApplicationStateActive
    
    // 歌曲封面
    static UIImage *artworkImage;
    if (_index == self.currectLyricIndex) {
    }else{
        _index = self.currectLyricIndex;
        artworkImage = [CLMusicLyricModel lockScreenImageWithLyrics:self.musicModel.lyrics
                                                       currentIndex:self.currectLyricIndex
                                                    backgroundImage:self.musicModel.thumbImage];
    }
    
    MPMediaItemArtwork *itemArtwork = [[MPMediaItemArtwork alloc] initWithImage:artworkImage];
    
    /*  播放信息中心，用于控制锁屏界面显示的内容
     MPMediaItemPropertyAlbumTitle       专辑
     MPMediaItemPropertyTitle            歌名
     MPMediaItemPropertyArtist           歌手
     MPMediaItemPropertyArtwork          歌曲封面
     MPMediaItemPropertyComposer         编曲
     MPMediaItemPropertyPlaybackDuration 持续时间
     MPNowPlayingInfoPropertyElapsedPlaybackTime  当前播放时间
     */
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    infoCenter.nowPlayingInfo = @{
                                  MPMediaItemPropertyAlbumTitle : self.musicModel.album,
                                  MPMediaItemPropertyArtist : self.musicModel.singerName,
                                  MPMediaItemPropertyTitle : self.musicModel.songName,
                                  MPMediaItemPropertyPlaybackDuration : @(self.durationTime),
                                  MPNowPlayingInfoPropertyElapsedPlaybackTime : @(self.currentTime),
                                  MPMediaItemPropertyArtwork : itemArtwork,
                                  };
}

#pragma mark 时间格式转换
- (NSString *)cl_formatTime:(NSTimeInterval)duration {
    if (duration <= 0 || isnan(duration)) {
        return @"00:00";
    }
    NSInteger minute = (int)duration / 60;
    NSInteger second = (int)duration % 60;
    return [NSString stringWithFormat:@"%.02ld:%.02ld", (long)minute, (long)second];
}

#pragma mark 为数组随机排序
- (NSArray *)cl_randomArray:(NSArray *)array {
    NSArray *randomArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int seed = arc4random_uniform(2);   // 生成0～(2-1)的随机数
        if (seed) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return randomArray;
}

@end
