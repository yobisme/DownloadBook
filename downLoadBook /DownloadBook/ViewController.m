//
//  ViewController.m
//  DownloadBook
//
//  Created by Macx on 2016/5/13.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import "ViewController.h"
#import <YYModel.h>
#import "BookModel.h"
#import "BookTableViewCell.h"
#import "FileDownloadManager.h"

@interface ViewController () <BookTableViewCellDelegate>

@property (nonatomic,strong)NSArray * listArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self loadData];
}


/**
 加载数据
 */
- (void)loadData
{
    NSURL *url = [NSURL URLWithString:@"http://42.62.15.101/yyting/bookclient/ClientGetBookResource.action?bookId=30776&imei=OEVGRDQ1ODktRUREMi00OTU4LUE3MTctOUFGMjE4Q0JDMTUy&nwt=1&pageNum=1&pageSize=50&q=114&sc=acca7b0f8bcc9603c25a52f572f3d863&sortType=0&token=KMSKLNNITOFYtR4iQHIE2cE95w48yMvrQb63ToXOFc8%2A"];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil)
        {
            
            NSDictionary *jsonDit = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSArray *array = jsonDit[@"list"];
            
            self.listArray = [NSArray yy_modelArrayWithClass:[BookModel class] json:array];
      
            //NSLog(@"%@",self.listArray);
            
            [self.tableView reloadData];
            
        }else
        {
            NSLog(@"%@",error);
        }
   
    }] resume];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell" forIndexPath:indexPath];
    
    BookModel *model = self.listArray[indexPath.row];
    
    cell.model = model;
    
    cell.delegate = self;
    
    return cell;
    
}

// 代理方法
- (void)clickDownloadButton:(BookTableViewCell *)bookTableViewCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:bookTableViewCell];
    
    BookModel *model = self.listArray[indexPath.row];
    
    if([[FileDownloadManager sharedManager] isDownloadingWithUrlStr:model.path] == YES)
    {
        [[FileDownloadManager sharedManager] pauseDownloadWithUrlStr:model.path pauseBlock:^{
            NSLog(@"暂停成功");
        }];
    }else{
        
        //NSLog(@"%zd",indexPath.row);
        [[FileDownloadManager sharedManager] downloadWithUrlStr:model.path progressBlock:^(float progress) {
            
            model.progress = progress;
            
            NSLog(@"%f",progress);
            
            BookTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            cell.model = model;
            
        }completionBlock:^(NSString *savePath) {
            
            NSLog(@"%@",savePath);
        
        }];
    }
   
}

@end
