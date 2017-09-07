//
//  ViewController.h
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLMusicPlayer.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CLMusicPlayerProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UIButton *playerButton;
@property (weak, nonatomic) IBOutlet UIButton *listsButton;

@property (strong, nonatomic) NSMutableArray *musicsArray;
@property (nonatomic, strong) CLMusicPlayer *musicPlayer;

@end

