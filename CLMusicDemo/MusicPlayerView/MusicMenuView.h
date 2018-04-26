//
//  MusicMenuView.h
//  MuVR
//
//  Created by 思久科技 on 2017/4/1.
//  Copyright © 2017年 VR-MU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicPlayerViewController.h"

@interface MusicMenuView : UIView<UITableViewDelegate, UITableViewDataSource> {
    NSArray *_array;
}

@property (weak, nonatomic) IBOutlet UIView *bg;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;

+ (instancetype)sharedInstance;

- (void)showWithData:(NSArray *)array;

@end


/// 消息列表
@interface MusicMenuCell : UITableViewCell

@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *numberLabel;

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *albumLabel;

@property (nonatomic, retain) UIButton *deleteBtn;

- (void)setModel:(CLMusicModel *)model index:(NSUInteger)index isPlaying:(BOOL)isPlaying;

@end
