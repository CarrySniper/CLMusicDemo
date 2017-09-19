//
//  TableViewCell.m
//  CLMusicDemo
//
//  Created by 炬盈科技 on 2017/9/6.
//  Copyright © 2017年 CJQ. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)setModel:(CLMusicModel *)model
{
    self.nameLabel.text = model.songName;
    self.singerLabel.text = model.singerName;
    [self.thumbImage setImageWithURL:[NSURL URLWithString:model.thumb]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
