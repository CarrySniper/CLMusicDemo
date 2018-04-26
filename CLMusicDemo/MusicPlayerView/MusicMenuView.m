//
//  MusicMenuView.m
//  MuVR
//
//  Created by 思久科技 on 2017/4/1.
//  Copyright © 2017年 VR-MU. All rights reserved.
//

#import "MusicMenuView.h"
// 只要添加了这个宏，就不用带mas_前缀
#define MAS_SHORTHAND
// 只要添加了这个宏，equalTo就等价于mas_equalTo
#define MAS_SHORTHAND_GLOBALS
// 这个头文件一定要放在上面两个宏的后面
#import <Masonry.h>

#define DeviceWidth    ([UIScreen mainScreen].bounds.size.width)
#define DeviceHeight   ([UIScreen mainScreen].bounds.size.height)

@implementation MusicMenuView

+ (instancetype)sharedInstance {
    return [[self alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"MusicMenuView" owner:self options:nil];
        //得到第一个UIView
        self = (MusicMenuView *)[nib objectAtIndex:0];
    }
    return self;
}

static bool _isShow = NO;
- (void)showWithData:(NSArray *)array
{
    _array = array;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.countLabel.text = [NSString stringWithFormat:@"（共%ld首）", (unsigned long)[_array count]];
        [self.tableView reloadData];
    });
    
    if (_isShow) {
        return;
    }
    _isShow = YES;
    self.frame = CGRectMake(0, DeviceHeight, DeviceWidth, DeviceHeight);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = [UIScreen mainScreen].bounds;
    }]; 
}

#pragma mark - UITableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"MusicMenuCell";
    
    MusicMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MusicMenuCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    CLMusicModel *model = _array[indexPath.row];
    BOOL isPlaying = [[CLMusicPlayer sharedInstance].musicModel isEqual:model];
    [cell setModel:model index:indexPath.row+1 isPlaying:isPlaying];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)hide
{
    _isShow = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, DeviceHeight, DeviceWidth, DeviceHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50.0;
    self.tableView.tableFooterView = [UIView new];
    
    //===============================
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.bg addGestureRecognizer:singleRecognizer];
    //===============================
}

@end

// MARK: -
@implementation MusicMenuCell

- (void)setModel:(CLMusicModel *)model index:(NSUInteger)index isPlaying:(BOOL)isPlaying
{
    if (isPlaying) {
        _numberLabel.hidden = YES;
        _deleteBtn.hidden = YES;
        _deleteBtn.enabled = NO;
        _icon.hidden = NO;
        
        _numberLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)index];
    }else{
        _numberLabel.hidden = NO;
        _deleteBtn.hidden = NO;
        _deleteBtn.enabled = YES;
        _icon.hidden = YES;
        
        _numberLabel.text = @"";
    }
    
    _nameLabel.text = model.songName;
    _albumLabel.text = [NSString stringWithFormat:@"%@ - %@", model.singerName, model.album];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _numberLabel = [[UILabel alloc]init];
        _numberLabel.textColor = [UIColor blackColor];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_numberLabel];
        [_numberLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(30);
            make.height.equalTo(30);
        }];
        
        _icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"musicplaying"]];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_icon];
        [_icon makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(30);
            make.height.equalTo(13);
        }];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setTitle:@"X" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_deleteBtn];
        [_deleteBtn makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
            make.width.equalTo(30);
            make.height.equalTo(30);
        }];
        
        // ------------------------
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = [UIColor darkGrayColor];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(54);
            make.right.equalTo(_deleteBtn).offset(-16);
            make.bottom.equalTo(self.contentView.centerY);
        }];
        
        _albumLabel = [[UILabel alloc]init];
        _albumLabel.textColor = [UIColor grayColor];
        _albumLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_albumLabel];
        [_albumLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(54);
            make.right.equalTo(_nameLabel);
            make.top.equalTo(self.contentView.centerY);
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
