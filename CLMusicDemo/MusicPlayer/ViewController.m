//
//  ViewController.m
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "MusicPlayerViewController.h"

#import <AFNetworking.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /**
     *  设置视图UI的属性
     */
    [self setProperty];
    
    [self httpMusics];
    
    self.musicPlayer = [CLMusicPlayer instance];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.musicPlayer.protocol = self;
    // 设置状态
    [self musicPlayerStatusDidChange:self.musicPlayer.status];
}


- (void)httpMusics
{
    // http://www.sojson.com/api/qqmusic/692771080/json QQ音乐
    NSString *urlString = @"http://tingapi.ting.baidu.com/v1/restserver/ting?from=qianqian&version=2.1.0&method=baidu.ting.billboard.billList&format=json&type=1&offset=0&size=50";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", nil];
    
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [responseObject mutableCopy];
        NSArray *array = dict[@"song_list"];
        _musicsArray = [[NSArray yy_modelArrayWithClass:[CLMusicModel class] json:array] mutableCopy];
        
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请求失败" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

#pragma mark - UIControl
- (IBAction)playOrPauseAction:(id)sender {
    [[CLMusicPlayer instance] cl_musicPlayOrPause];
}

- (IBAction)showListsAction:(id)sender {
    
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

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CLMusicModel *model = _musicsArray[indexPath.row];
    model.songLink = @"http://www.hitow.net/music/link/58273.mp3";
    
    NSString *contentPath = [[NSBundle mainBundle] pathForResource:@"国王与乞丐" ofType:@"lrc"];
    NSString *lyric = [NSString stringWithContentsOfFile:contentPath encoding:NSUTF8StringEncoding error:nil];
    model.lyrics = [CLMusicLyricModel lyrics:lyric];
    
    MusicPlayerViewController *viewController = [[MusicPlayerViewController alloc]initWithMusicModel:model];
    [self.navigationController pushViewController:viewController animated:YES];    
    
    _nameLabel.text = model.songName;
    _singerLabel.text = model.singerName;
    [_thumbImage setImageWithURL:[NSURL URLWithString:model.thumb]];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_musicsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"TableViewCell";
    
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell= (TableViewCell *)[[[NSBundle  mainBundle]loadNibNamed:identifier owner:self options:nil]  lastObject];
    }
    
    CLMusicModel *model = _musicsArray[indexPath.row];
    [cell setModel:model];
//    cell.lyricLabel.text = model.content;
//    if (self.musicPlayer.currectLyricIndex == indexPath.row) {
//        cell.lyricLabel.textColor = COLOR_TEXT_SELECT;
//    }else{
//        cell.lyricLabel.textColor = [UIColor whiteColor];
//    }
    
    return cell;
}

#pragma mark - 设置视图UI的属性
- (void)setProperty
{
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.rowHeight = 60.0;    
    
    [self.playerButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playerButton setTitle:@"暂停" forState:UIControlStateSelected];
}

@end
