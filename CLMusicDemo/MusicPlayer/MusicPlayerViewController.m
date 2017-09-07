//
//  MusicPlayerViewController.m
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import "MusicPlayerViewController.h"

// 只要添加了这个宏，就不用带mas_前缀
#define MAS_SHORTHAND
// 只要添加了这个宏，equalTo就等价于mas_equalTo
#define MAS_SHORTHAND_GLOBALS
// 这个头文件一定要放在上面两个宏的后面
#import <Masonry.h>


@interface MusicPlayerViewController ()

@end

@implementation MusicPlayerViewController

- (instancetype)initWithMusicModel:(CLMusicModel *)musicModel
{
    self = [super init];
    if (self) {
        _musicModel = musicModel;
        
        self.musicPlayer = [CLMusicPlayer instance];
        self.musicPlayer.protocol = self;
        [self.musicPlayer cl_playMusic:musicModel];
        [self.musicPlayer cl_addRemoteCommandCenterWithTarget:self
                                                   playAction:@selector(playOrPauseAction:)
                                                  pauseAction:@selector(playOrPauseAction:)
                                               lastSongAction:@selector(lastAction:)
                                               nextSongAction:@selector(nextAction:)];
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
    [self musicPlayerStatusDidChange:self.musicPlayer.status];
}

#pragma mark - UIControl
- (IBAction)playOrPauseAction:(id)sender {
    [self.musicPlayer cl_musicPlayOrPause];
}
- (IBAction)lastAction:(id)sender {
}
- (IBAction)nextAction:(id)sender {
}

- (IBAction)beginProgressAction:(id)sender {
    [self.musicPlayer cl_seekToTimeBegin];
}
- (IBAction)didChangeProgressAction:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.currentTime.text = [self.musicPlayer formatTime:slider.value * [self.musicPlayer durationTime]];
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
#pragma mark 音乐播放状态
- (void)musicPlayerStatusDidChange:(CLMusicStatus)musicStatus {
    if (musicStatus == CLMusicStatusPlaying || musicStatus == CLMusicStatusReadyToPlay) {
        [self.playerButton setSelected:YES];
    }else{
        [self.playerButton setSelected:NO];
    }
}

#pragma mark 音乐缓存进度
- (void)musicPlayerCacheProgress:(float)progress {
    self.progressView.progress = progress;
    self.totalTime.text = [self.musicPlayer formatTime:[self.musicPlayer durationTime]];
}

#pragma mark 音乐播放进度
- (void)musicPlayerPlayingProgress:(float)progress {
    self.progressSlider.value = progress;
    self.currentTime.text = [self.musicPlayer formatTime:[self.musicPlayer currentTime]];
    self.totalTime.text = [self.musicPlayer formatTime:[self.musicPlayer durationTime]];
}

#pragma mark 音乐歌词当前下标
- (void)musicPlayerLyricIndex:(NSInteger)lyricIndex {
    if ([_musicModel.lyrics count] > 0 && isLyricScroll == NO) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lyricIndex inSection:0];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - UIScrollView DataSource
static bool isLyricScroll = NO;  // 标记是否手动滚动歌词
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        isLyricScroll = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        if ([_musicModel.lyrics count] > 0 && isLyricScroll) {
            CGPoint center = CGPointMake(0, _tableView.contentOffset.y + _tableView.frame.size.height / 2);
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:center];
            CLMusicLyricModel *model = _musicModel.lyrics[indexPath.row];
            NSLog(@"歌词滚动到时间：%@", [self.musicPlayer formatTime:model.beginTime]);
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        isLyricScroll = NO;
    }
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_musicModel.lyrics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"MusicPlayerCell";
    
    MusicPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MusicPlayerCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    CLMusicLyricModel *model = _musicModel.lyrics[indexPath.row];
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
