//
//  CLMusicPlayer.m
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import "CLMusicPlayer.h"

@interface CLMusicPlayer()

// 本类中的播放器指针
@property (nonatomic, strong) AVPlayer *player;
// 播放器状态监听
@property (nonatomic, strong) id playTimeObserver;
// 当前播放的音乐Model
@property (nonatomic, strong, readonly) CLMusicModel *musicModel;

/** 是否正在跳转播放时间 */
@property (nonatomic, assign) BOOL isSeeking;

@end

@implementation CLMusicPlayer

#pragma mark - 初始化
+ (instancetype)instance {
    return [[self alloc] init];
}

- (instancetype)init
{
    static CLMusicPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    });
    return instance;
}

- (void)dealloc
{
    [self removePlayerListener];
    self.player = nil;
}

#pragma mark 开始播放音乐
- (void)cl_playMusic:(CLMusicModel *)musicModel
{
    if ([_musicModel isEqual:musicModel]) {
        return;// 避免过分调用
    }
    _musicModel = musicModel;
    
    self.player = [self playingWithUrlString:musicModel.songLink];
    [self.player play];
    self.status = CLMusicStatusPlaying;
}

#pragma mark 音乐播放暂停
- (void)cl_musicPlayOrPause
{
    if (self.player == nil) {
        // 还没有选择音乐
        return ;
    }
    
    if (_player.rate == 0 || _player.error) {
        // 不是播放状态或者有错误，都可以进行播放操作
        [self.player play];
        self.status = CLMusicStatusPlaying;
    }else{
        // 否则都做暂停操作
        [self.player pause];
        self.status = CLMusicStatusPause;
    }
}
#pragma mark 跳转音乐进度
- (void)cl_seekToTimeBegin {
    self.isSeeking = YES;
}

- (void)cl_seekToTimeEndWithProgress:(CGFloat)progress completionHandler:(void (^)())completionHandler {
    CMTime changedTime = CMTimeMake(self.durationTime * progress, 1.0);
    [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        if (finished) {
            self.isSeeking = NO;
            completionHandler();
        }
    }];
}

#pragma mark 添加远程控制中心
- (void)cl_addRemoteCommandCenterWithTarget:(id)target
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
- (void)cl_updateLockScreen {
    // MARK 歌词不变或者app前台运行不需要锁屏歌词
    if (_index == _currectLyricIndex ||
        [UIApplication sharedApplication].applicationState == UIApplicationStateActive ||
        [UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        return;
    }else{
        _index = _currectLyricIndex;
    }
    
    // 歌曲封面
    UIImage *artworkImage = [CLMusicLyricModel lockScreenImageWithLyrics:self.musicModel.lyrics
                                                            currentIndex:_currectLyricIndex
                                                         backgroundImage:self.musicModel.thumbImage];
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

#pragma mark - setting getting方法
#pragma mark 播放媒体链接（内部方法）
- (AVPlayer *)playingWithUrlString:(NSString *)urlString
{
    AVPlayerItem *playerItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:urlString]];
    if (self.player == nil) {
        self.player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
        // AVPlayer只初始化一次，添加|移除 监听也只操作一次
        [self addPlayerListener];
        [self addPlayerItemListener];
    }else {
        // AVPlayerItem会多次生成，也需要多次移除
        [self removePlayerItemListener];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [self addPlayerItemListener];
    }
    return self.player;
}

#pragma mark 设置播放状态，会调用代理
- (void)setStatus:(CLMusicStatus)status {
    if (_status == status) {
        return;// 避免过分调用
    }
    _status = status;
    
    if (self.protocol && [self.protocol respondsToSelector:@selector(musicPlayerStatusDidChange:)]) {
        [self.protocol musicPlayerStatusDidChange:status];
    }
}

#pragma mark 当前播放时间
- (NSTimeInterval)currentTime {
    if (CMTimeGetSeconds(self.player.currentItem.currentTime) > self.durationTime) {
        return self.durationTime;
    }
    if (CMTimeGetSeconds(self.player.currentItem.currentTime) <= 0.0) {
        return 0.0;
    }
    return CMTimeGetSeconds(self.player.currentItem.currentTime);
}

#pragma mark 总时间
- (NSTimeInterval)durationTime {
    return CMTimeGetSeconds(self.player.currentItem.duration);
}

#pragma mark 缓存时间
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [self.player.currentItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark 时间格式转换
- (NSString *)formatTime:(NSTimeInterval)duration {
    if (duration == 0) {
        return @"00:00";
    }
    NSInteger minute = (int)duration / 60;
    NSInteger second = (int)duration % 60;
    return [NSString stringWithFormat:@"%.02ld:%.02ld", (long)minute, (long)second];
}

#pragma mark - PlayerItem监听
- (void)addPlayerItemListener
{
    // KVO
    AVPlayerItem *playerItem = self.player.currentItem;
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removePlayerItemListener {
    AVPlayerItem *playerItem = self.player.currentItem;
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = self.player.currentItem.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay: {   NSLog(@"AVPlayerItemStatusReadyToPlay");
                self.status = CLMusicStatusReadyToPlay;
            }
                break;
            case AVPlayerItemStatusUnknown: {   NSLog(@"AVPlayerItemStatusUnknown");
                self.status = CLMusicStatusPause;
                [self.player pause];
            }
                break;
            case AVPlayerItemStatusFailed: {    NSLog(@"AVPlayerItemStatusFailed");
                self.status = CLMusicStatusPause;
                [self.player.currentItem cancelPendingSeeks];
                [self.player pause];
            }
                break;
                
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {    NSLog(@"loadedTimeRanges");
        self.status = CLMusicStatusPlaying;
        // MARK: 缓存进度
        if (self.protocol && [self.protocol respondsToSelector:@selector(musicPlayerCacheProgress:)]) {
            [self.protocol musicPlayerCacheProgress:(self.availableDuration / self.durationTime)];
        }
    } else {
        NSLog(@"其他问题");
    }
}
#pragma mark - Player监听
- (void)addPlayerListener {
    
    // Notification
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 添加异常中断通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStalled:)
                                                 name:AVPlayerItemPlaybackStalledNotification object:nil];
    // 进入后台，一些耗性能的动作要暂停
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBcakground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    // 返回前台，恢复需要的动作
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeForeground)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // KVO
    __weak typeof(self)weakSelf = self;
    CMTime time = CMTimeMake(1, 4); // 观察间隔, CMTime 为1/4秒
    self.playTimeObserver = [self.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time) {
        // FIXME: 当正在拖动滑块，修改播放时间的时候，就不需要自动更新了
        if (!weakSelf.isSeeking) {
            // MARK: 播放进度
            if (weakSelf.protocol && [weakSelf.protocol respondsToSelector:@selector(musicPlayerPlayingProgress:)]) {
                [weakSelf.protocol musicPlayerPlayingProgress:(weakSelf.currentTime / weakSelf.durationTime)];
            }
            
            [weakSelf updateTheCurrentLyricIndex];
        }
    }];
}

#pragma mark -  更新歌词显示
- (void)updateTheCurrentLyricIndex {
    // MARK: 歌词进度
    if (self.protocol && [self.protocol respondsToSelector:@selector(musicPlayerLyricIndex:)]) {
        NSInteger currectLyricIndex = 0;
        for (CLMusicLyricModel *model in self.musicModel.lyrics) {
            if(self.currentTime >= model.beginTime - 0.28) {// 提前0.28s
                currectLyricIndex = [self.musicModel.lyrics indexOfObject:model];
            }else
                break;
        }
        if (currectLyricIndex == self.currectLyricIndex) {
            return;// 避免过分调用
        }
        self.currectLyricIndex = currectLyricIndex;
        [self.protocol musicPlayerLyricIndex:(self.currectLyricIndex)];
        [self cl_updateLockScreen];
    }
}


- (void)removePlayerListener {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.player removeTimeObserver:_playTimeObserver];
}

- (void)movieToEnd:(NSNotification *)notification {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    self.status = CLMusicStatusFinish;
    [self.player pause];
//    // 播放结束
//    if (self.endBlock) dispatch_async(dispatch_get_main_queue(), ^{
//        self.endBlock();
//    });
}
- (void)movieStalled:(NSNotification *)notification {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [_player pause];
    
}
- (void)enterBcakground {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}
- (void)becomeForeground {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


@end
