//
//  BookModel.h
//  DownloadBook
//
//  Created by Macx on 2016/5/13.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookModel : NSObject

@property (nonatomic,strong)NSString *name;

@property (nonatomic,strong)NSString *path;

@property(nonatomic,assign,getter=isButSelected)BOOL butSelected;

//记录进度
@property (nonatomic,assign)float progress;

@end
