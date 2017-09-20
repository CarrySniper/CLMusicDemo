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
    
    if (self.protocol && [self.protocol respondsToSelector:@selector(musicPlayerReplaceMusic:)]) {
        [self.protocol musicPlayerReplaceMusic:musicModel];
    }
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

#pragma mark 停止播放
- (void)cl_musicStop
{
    [self.player pause];
    self.status = CLMusicStatusFinish;
    [self.player seekToTime:CMTimeMake(0.0, 1.0)];
    // MARK: 播放进度
    if (self.protocol && [self.protocol respondsToSelector:@selector(musicPlayerPlayingProgress:)]) {
        [self.protocol musicPlayerPlayingProgress:0.0];
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
            if (completionHandler) completionHandler();
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
    // MARK 歌词不变或者app前台运行不需要锁屏歌词，但iOS10控制中心在前台也是需要的……
    // [UIApplication sharedApplication].applicationState == UIApplicationStateActive
    
    // 歌曲封面
    static UIImage *artworkImage;
    if (_index == _currectLyricIndex) {
    }else{
        _index = _currectLyricIndex;
        artworkImage = [CLMusicLyricModel lockScreenImageWithLyrics:self.musicModel.lyrics
                                                       currentIndex:_currectLyricIndex
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
    
    if (self.protocol && [self.protocol respondsToSelector:@selector(musicPlayerStatusChange:)]) {
        [self.protocol musicPlayerStatusChange:status];
    }
}

#pragma mark 当前播放时间
- (NSTimeInterval)currentTime {
    if (CMTimeGetSeconds(self.player.currentItem.currentTime) > self.durationTime) {
        return [self durationTime];
    }
    if (CMTimeGetSeconds(self.player.currentItem.currentTime) < 0.0) {
        return 0.0;
    }
    return CMTimeGetSeconds(self.player.currentItem.currentTime);
}

#pragma mark 总时间
- (NSTimeInterval)durationTime {
    if (CMTimeGetSeconds(self.player.currentItem.duration) < 0.0) {
        return 0.0;
    }
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 添加异常中断通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStalled:)
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
            
            if (self.musicModel.lyrics.count > 0) {
                [weakSelf updateTheCurrentLyricIndex];
            }else{
                [weakSelf cl_updateLockScreen];
                weakSelf.currectLyricIndex = -1;
            }
        }
    }];
}

#pragma mark -  更新歌词显示
- (void)updateTheCurrentLyricIndex {
    // MARK: 歌词进度
    if (self.protocol && [self.protocol respondsToSelector:@selector(musicPlayerLyricIndex:)]) {
        static NSInteger currectLyricIndex = 0;
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

- (void)playerToEnd:(NSNotification *)notification {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    self.status = CLMusicStatusFinish;
    [self.player pause];
    // MARK: 播放结束
    if (self.protocol && [self.protocol respondsToSelector:@selector(musicPlayerEndPlay)]) {
        [self.protocol musicPlayerEndPlay];
    }
}
- (void)playerStalled:(NSNotification *)notification {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [_player play];
}
- (void)enterBcakground {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}
- (void)becomeForeground {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}


@end
