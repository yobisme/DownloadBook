//
//  FileDownloadManager.m
//  DownloadBook
//
//  Created by Macx on 2016/5/13.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import "FileDownloadManager.h"

@interface FileDownloadManager () <NSURLSessionDownloadDelegate>

@property (nonatomic,strong)NSURLSession * downloadSession;
//进度缓存池
@property (nonatomic,strong)NSMutableDictionary * progressDictM;
//下载完成后保存路径缓存池
@property (nonatomic,strong)NSMutableDictionary * savePathDictM;
//downloadTask 缓存池,记录是否有下载操作
@property (nonatomic,strong)NSMutableDictionary * downloadTaskDictM;
@end

@implementation FileDownloadManager


+ (instancetype)sharedManager
{
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];

        
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init] )
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"hh"];
        
        self.downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue new]];
        
        self.progressDictM = [NSMutableDictionary dictionary];
        
        self.savePathDictM = [NSMutableDictionary dictionary];
        
        self.downloadTaskDictM = [NSMutableDictionary dictionary];
    }
    return self;
}


//下载主方法
- (void)downloadWithUrlStr:(NSString *)urlStr progressBlock:(void (^)(float))progressBlock completionBlock:(void (^)(NSString *))completionBlock
{
    NSURL *url  = [NSURL URLWithString:urlStr];
    
    NSURLSessionDownloadTask *downloadDataTask;

    NSString *savePath = [NSString stringWithFormat:@"/Users/Macx/Desktop/%@.tmp",url.lastPathComponent];
    
    NSData *resumeData = [NSData dataWithContentsOfFile:savePath];
    
    if(resumeData != nil)
    {
        downloadDataTask = [self.downloadSession downloadTaskWithResumeData:resumeData];
        
        [[NSFileManager defaultManager] removeItemAtPath:savePath error:NULL];
        
    }else{
         downloadDataTask = [self.downloadSession downloadTaskWithURL:url];
    }
    
    [self.progressDictM setObject:progressBlock forKey:downloadDataTask];
    
    [self.savePathDictM setObject:completionBlock forKey:downloadDataTask];
    
    [self.downloadTaskDictM setObject:downloadDataTask forKey:urlStr];
    
    [downloadDataTask resume];
    
}



//完成下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didFinishDownloadingToURL:(NSURL *)location
{
    NSString *pathStr = downloadTask.currentRequest.URL.absoluteURL.lastPathComponent;
    
    NSString *savePath = [NSString stringWithFormat:@"/Users/Macx/Desktop/%@",pathStr];
    
    [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:savePath error:NULL];
    
    void(^savePathBlock)(NSString *) = [self.savePathDictM objectForKey:downloadTask];
    
    if (savePathBlock)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            savePathBlock(savePath);
        }];
    }
    
    
    //下载完成移除相应的
    [self.progressDictM removeObjectForKey:downloadTask];
    
    [self.savePathDictM removeObjectForKey:downloadTask];
    
    [self.downloadTaskDictM removeObjectForKey:downloadTask.currentRequest.URL.absoluteString];
}


//获取进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didWriteData:(int64_t)bytesWritten
    totalBytesWritten:(int64_t)totalBytesWritte
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritte / totalBytesExpectedToWrite;
    
    void(^progressBlock)(float) = [self.progressDictM objectForKey:downloadTask];
    
    if (progressBlock)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            progressBlock(progress);
        }];
    }
    
}

//通过缓存池里面是否有downloadTask,判断是否正在下载
- (BOOL)isDownloadingWithUrlStr:(NSString *)urlStr
{
    if ([self.downloadTaskDictM objectForKey:urlStr] != nil)
    {
        return YES;
    }
 
    return NO;
}
//暂停下载
- (void)pauseDownloadWithUrlStr:(NSString *)urlStr pauseBlock:(void (^)())pauseBlock
{
    NSURLSessionDownloadTask *downloadTask = [self.downloadTaskDictM objectForKey:urlStr];
    
    if (downloadTask) {
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
            NSString *pathStr = downloadTask.currentRequest.URL.absoluteURL.lastPathComponent;
            
            NSString *savePath = [NSString stringWithFormat:@"/Users/Macx/Desktop/%@.tmp",pathStr];
            
            [resumeData writeToFile:savePath atomically:YES];
            
            [self.progressDictM removeObjectForKey:downloadTask];
            
            [self.savePathDictM removeObjectForKey:downloadTask];
            
            [self.downloadTaskDictM removeObjectForKey:urlStr];
            
        }];
        
        if (pauseBlock) {
            pauseBlock();
        }
        
    }

}

@end
