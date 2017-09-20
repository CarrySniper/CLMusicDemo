//
//  MusicPlayerViewController.m
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "MusicMenuView.h"

// 只要添加了这个宏，就不用带mas_前缀
#define MAS_SHORTHAND
// 只要添加了这个宏，equalTo就等价于mas_equalTo
#define MAS_SHORTHAND_GLOBALS
// 这个头文件一定要放在上面两个宏的后面
#import <Masonry.h>

#import <AFNetworking.h>
#import <SVProgressHUD.h>


@interface MusicPlayerViewController ()

@end

@implementation MusicPlayerViewController

- (instancetype)initWithMusicModel:(CLMusicModel *)currentMusicModel withMusics:(NSArray *)defaultMusics
{
    self = [super init];
    if (self) {
        
        _defaultMusics = defaultMusics;
        
        self.musicPlayer = [CLMusicPlayer instance];
        [self.musicPlayer setProtocol:self];
                
        // 远程控制类
        [self.musicPlayer cl_addRemoteCommandCenterWithTarget:self
                                                   playAction:@selector(playOrPauseAction:)
                                                  pauseAction:@selector(playOrPauseAction:)
                                               lastSongAction:@selector(lastAction:)
                                               nextSongAction:@selector(nextAction:)];
        
        // FIXME: 当前播放模式，需要自己关联用户信息，持久化保持会好一点
        [self switchMusicPlayMode:0];
        self.title = currentMusicModel.songName;
        [self playingMusic:currentMusicModel];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /**
     *  设置视图UI的属性
     */
    [self setProperty];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置状态
    [self musicPlayerStatusChange:self.musicPlayer.status];
}

// FIXME: 这里是根据音乐id来获取音乐链接的，要根据实际需求替换这个方法
- (void)playingMusic:(CLMusicModel *)musicModel {
    if ([self.musicPlayer.musicModel.songId isEqualToString:musicModel.songId]) {
        return;
    }
    // 歌词直接读取链接，未做本地存储。
    //unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *lyric = [NSString stringWithContentsOfURL:[NSURL URLWithString:musicModel.lyricLink] encoding:NSUTF8StringEncoding error:nil];
    musicModel.lyrics = [CLMusicLyricModel lyrics:lyric];
    
    NSString *urlString = [NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?from=android&version=2.4.0&method=baidu.ting.song.play&songid=%@", musicModel.songId];
    
    [SVProgressHUD showWithStatus:@"(>﹏<)"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", nil];
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"加载完成(^_^)"];
        [SVProgressHUD dismissWithDelay:1.0];
        
        NSDictionary *dict = [responseObject mutableCopy];
        NSDictionary *songurl = dict[@"bitrate"];
        musicModel.songLink = songurl[@"show_link"];
        [self.musicPlayer cl_playMusic:musicModel];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求失败" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

#pragma mark - UIControl
#pragma mark 播放暂停
- (IBAction)playOrPauseAction:(id)sender {
    [self.musicPlayer cl_musicPlayOrPause];
}

#pragma mark 上一首
- (IBAction)lastAction:(id)sender {
    NSUInteger currentIndex = [_currentMusics indexOfObject:_musicPlayer.musicModel];
    if (currentIndex <= 0) {
        if (self.musicPlayMode == MusicPlayMode_ListReplay) {
            CLMusicModel *model = _currentMusics.lastObject;
            [self playingMusic:model];
        }else{
            NSLog(@"没有上一首啦");
        }
    }else{
        CLMusicModel *model = _currentMusics[currentIndex - 1];
        [self playingMusic:model];
    }
}

#pragma mark 下一首
- (IBAction)nextAction:(id)sender {
    NSUInteger currentIndex = [_currentMusics indexOfObject:_musicPlayer.musicModel];
    if (currentIndex >= _currentMusics.count - 1) {
        if (self.musicPlayMode == MusicPlayMode_ListReplay) {
            CLMusicModel *model = _currentMusics.firstObject;
            [self playingMusic:model];
        }else{
            NSLog(@"没有下一首啦");
        }
    }else{
        CLMusicModel *model = _currentMusics[currentIndex + 1];
        [self playingMusic:model];
    }
}

#pragma mark 播放模式
- (IBAction)modeAction:(id)sender {
    if (_musicPlayMode > 3) {
        self.musicPlayMode = 0;
    }else{
        self.musicPlayMode++;
    }
    [self switchMusicPlayMode:self.musicPlayMode];
}
- (void)switchMusicPlayMode:(MusicPlayMode)musicPlayMode {
    switch (musicPlayMode) {
        case MusicPlayMode_Nomal: {
            [_modeButton setTitle:@"顺序" forState:UIControlStateNormal];
            _currentMusics = [_defaultMusics mutableCopy];
        }
            break;
        case MusicPlayMode_SingalReplay: {
            [_modeButton setTitle:@"单曲" forState:UIControlStateNormal];
            _currentMusics = [_defaultMusics mutableCopy];
        }
            break;
        case MusicPlayMode_ListReplay: {
            [_modeButton setTitle:@"循环" forState:UIControlStateNormal];
            _currentMusics = [_defaultMusics mutableCopy];
        }
            break;
        case MusicPlayMode_RandomPlay: {
            [_modeButton setTitle:@"随机" forState:UIControlStateNormal];
            _currentMusics = [self.musicPlayer cl_randomArray:_defaultMusics];
        }
            break;
        default:
            break;
    }
}

#pragma mark 播放列表（顺序修改后的）
- (IBAction)listAction:(id)sender {
    
    [[MusicMenuView instance] showWithData:self.currentMusics];
}

#pragma mark UISlider 拖动修改播放进度
- (IBAction)beginProgressAction:(id)sender {
    [self.musicPlayer cl_seekToTimeBegin];
}
- (IBAction)didChangeProgressAction:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.currentTime.text = [self.musicPlayer cl_formatTime:slider.value * [self.musicPlayer durationTime]];
}
- (IBAction)endProgressAction:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if (self.musicPlayer.durationTime > 0) {
        [self.musicPlayer cl_seekToTimeEndWithProgress:slider.value completionHandler:^{
            // 设为播放中 可暂停状态
        }];
    }else{
        [slider setValue:0.0 animated:YES];
    }
}

#pragma mark - CLMusicPlayer Protocol
#pragma mark 音乐切换回调（切歌）
- (void)musicPlayerReplaceMusic:(CLMusicModel *)musicModel {
    self.title = musicModel.songName;
}

#pragma mark 音乐播放状态
- (void)musicPlayerStatusChange:(CLMusicStatus)musicStatus {
    if (musicStatus == CLMusicStatusPlaying || musicStatus == CLMusicStatusReadyToPlay) {
        [self.playerButton setSelected:YES];
    }else{
        [self.playerButton setSelected:NO];
    }
}

#pragma mark 音乐缓存进度
- (void)musicPlayerCacheProgress:(float)progress {
    self.progressView.progress = progress;
    self.totalTime.text = [self.musicPlayer cl_formatTime:[self.musicPlayer durationTime]];
}

#pragma mark 音乐播放进度
- (void)musicPlayerPlayingProgress:(float)progress {
    self.progressSlider.value = progress;
    self.currentTime.text = [self.musicPlayer cl_formatTime:[self.musicPlayer currentTime]];
    self.totalTime.text = [self.musicPlayer cl_formatTime:[self.musicPlayer durationTime]];
}

#pragma mark 音乐播放结束
- (void)musicPlayerEndPlay {
    if (_musicPlayMode == MusicPlayMode_SingalReplay) {
        // 单曲循环
        [self.musicPlayer cl_seekToTimeEndWithProgress:0.0 completionHandler:nil];
    }else{
        [self nextAction:nil];
    }
}

#pragma mark 音乐歌词当前下标
- (void)musicPlayerLyricIndex:(NSInteger)lyricIndex {
    if ([_musicPlayer.musicModel.lyrics count] > 0 && isLyricScroll == NO) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lyricIndex inSection:0];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - UIScrollView DataSource
static bool isLyricScroll = NO;  // 标记是否手动滚动歌词
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && [_musicPlayer.musicModel.lyrics count]) { // 预防过度操作和崩溃
        isLyricScroll = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && [_musicPlayer.musicModel.lyrics count]) { // 预防过度操作和崩溃
        if (isLyricScroll) {
            CGPoint center = CGPointMake(0, _tableView.contentOffset.y + _tableView.frame.size.height / 2);
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:center];
            CLMusicLyricModel *model = _musicPlayer.musicModel.lyrics[indexPath.row];
            NSLog(@"歌词滚动到时间：%@", [self.musicPlayer cl_formatTime:model.beginTime]);
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && [_musicPlayer.musicModel.lyrics count]) { // 预防过度操作和崩溃
        isLyricScroll = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.musicPlayer.currectLyricIndex inSection:0];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_musicPlayer.musicModel.lyrics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"MusicPlayerCell";
    
    MusicPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MusicPlayerCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    CLMusicLyricModel *model = _musicPlayer.musicModel.lyrics[indexPath.row];
    cell.lyricLabel.text = model.content;
    if (self.musicPlayer.currectLyricIndex == indexPath.row) {
        cell.lyricLabel.textColor = [UIColor redColor];
    }else{
        cell.lyricLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}

#pragma mark - 设置视图UI的属性
- (void)setProperty
{
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.rowHeight = 30.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.playerButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playerButton setTitle:@"暂停" forState:UIControlStateSelected];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

// MARK: -
@implementation MusicPlayerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.autoresizesSubviews = YES;
        
        _lyricLabel = [[UILabel alloc]init];
        _lyricLabel.textAlignment = NSTextAlignmentCenter;
        _lyricLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_lyricLabel];
        [_lyricLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.imageView removeFromSuperview];
    [self.textLabel removeFromSuperview];
}
@end
