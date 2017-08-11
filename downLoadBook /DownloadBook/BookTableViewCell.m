//
//  BookTableViewCell.m
//  DownloadBook
//
//  Created by Macx on 2016/5/13.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import "BookTableViewCell.h"

@interface BookTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end
@implementation BookTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    UIButton *button = [[UIButton alloc] init];
    
    [self.contentView addSubview:button];
    
    self.accessoryView = button;
    
    [button setTitle:@"下载" forState:UIControlStateNormal];
    
    [button setTitle:@"暂停" forState:UIControlStateSelected];
    
    [button sizeToFit];
    
    button.backgroundColor = [UIColor redColor];
    
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
 
}


- (void)clickButton:(UIButton *)selectedButton
{
    self.model.butSelected = !self.model.isButSelected;
    
    [selectedButton setTitle:(self.model.butSelected== YES ?@"暂停":@"下载") forState:UIControlStateNormal];
    
    
    if ([self.delegate respondsToSelector:@selector(clickDownloadButton:)])
    {
        [self.delegate clickDownloadButton:self];
    }
    
}

- (void)setModel:(BookModel *)model
{
    _model = model;
    
    self.nameLabel.text = model.name;
    
    UIButton *clickBut = (UIButton *)self.accessoryView;
    
    [clickBut setTitle:(self.model.butSelected== YES ?@"暂停":@"下载") forState:UIControlStateNormal];
    
    
    self.progressView.progress = model.progress;

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}

@end
