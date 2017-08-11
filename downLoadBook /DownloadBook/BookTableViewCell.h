//
//  BookTableViewCell.h
//  DownloadBook
//
//  Created by Macx on 2016/5/13.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BookModel.h"

@class BookTableViewCell;

@protocol BookTableViewCellDelegate <NSObject>

- (void)clickDownloadButton:(BookTableViewCell *)bookTableViewCell;

@end

@interface BookTableViewCell : UITableViewCell

@property (nonatomic,strong)BookModel *model;

@property (nonatomic,strong)id delegate;



@end
