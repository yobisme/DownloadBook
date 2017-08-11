//
//  FileDownloadManager.h
//  DownloadBook
//
//  Created by Macx on 2016/5/13.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownloadManager : NSObject
//单例
+ (instancetype)sharedManager;


/**
 下载主方法

 @param urlStr 路径
 @param progressBlock 进度回调
 @param completionBlock 完成回调
 */
- (void)downloadWithUrlStr:(NSString *)urlStr progressBlock:(void(^)(float progress))progressBlock completionBlock:(void(^)(NSString *savePath))completionBlock;

//是否正在下载
- (BOOL)isDownloadingWithUrlStr:(NSString *)urlStr;

//暂停下载
- (void)pauseDownloadWithUrlStr:(NSString *)urlStr pauseBlock:(void(^)())pauseBlock;
@end
