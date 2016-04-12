//
//  SSNetworkViewController.m
//  OHCardToolApp
//
//  Created by caoli on 16/4/8.
//  Copyright © 2016年 QingjianWu. All rights reserved.
//

#import "SSNetworkViewController.h"
#import "SSUploadHelper.h"


@interface SSNetworkViewController () <NSURLSessionDownloadDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSURLSession *defaultSession;
@property (nonatomic, strong) NSURLSession *ephemeralSession;

@property (nonatomic, strong) NSURL *downloadedLocation;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *boundary;

@end

@implementation SSNetworkViewController

@synthesize fileName = _fileName;

-(NSString*)boundary
{
    return @"WebKitFormBoundaryHaO4SQ0nB0ZZfp";
}

-(NSString*)fileName
{
    if (!_fileName) {
        _fileName = @"test.zip";
    }
    return _fileName;
}

-(void) setFileName:(NSString *)fileName
{
    _fileName = fileName;
}

-(NSURL*)downloadedLocation
{
    if (!_downloadedLocation) {
        
        NSError *err = nil;
        NSURL *path = [[NSFileManager defaultManager] URLForDirectory:NSDownloadsDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
        
        _downloadedLocation = [path URLByAppendingPathComponent:self.fileName];
        
    }
    return _downloadedLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(NSURLSession*) defaultSession
{
    if (!_defaultSession) {
        _defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _defaultSession;
}

-(NSURLSession*) backgroundSession
{
    if (!_backgroundSession) {
        _backgroundSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backgroundSessionId"] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    }
    return _backgroundSession;
}

-(NSURLSession*)ephemeralSession
{
    if (!_ephemeralSession) {
        _ephemeralSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    }
    return _ephemeralSession;
}

- (void)dataTask {
    NSURLSessionDataTask *dataTask = [self.defaultSession dataTaskWithURL:[NSURL URLWithString:@"http://192.168.31.172/iOSWebServer/index.html"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Got response %@ with error %@.\n", response, error);
        NSLog(@"DATA:\n%@\nEND DATA\n",
              [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
    [dataTask resume];
}

- (IBAction)load:(id)sender {

    //[self dataTask];
    [self downloadTask];
    
}
- (IBAction)upload:(id)sender {
    [self uploadFileWithHelper];
    //[self uploadTaskWithHelper];
    //[self uploadTask];
   // [self uploadFile];
}

-(void) downloadTask
{
    NSURL *url = [NSURL URLWithString:@"https://developer.apple.com/library/ios/samplecode/QuickSwitch/QuickSwitchSupportingQuickWatchSwitchingwithWatchConnectivity.zip"];
    //NSURL *url = [NSURL URLWithString:@""];
    self.fileName = [url lastPathComponent];
    NSURLSessionDownloadTask *downloadTask = [self.backgroundSession downloadTaskWithURL:url];
    
    [downloadTask resume];
}
-(void) uploadFileWithHelper
{
    SSUploadHelper *uploadHelper = [[SSUploadHelper alloc] initWithTarget:[NSURL URLWithString:@"http://192.168.31.172:5012/ArchFlow/upload"]  forSource:self.downloadedLocation];
    [NSURLConnection connectionWithRequest:uploadHelper.requestWithHeaderAndBody delegate:self];
}

-(void)uploadTaskWithHelper
{
    SSUploadHelper *uploadHelper = [[SSUploadHelper alloc] initWithTarget:[NSURL URLWithString:@"http://192.168.31.172:5012/ArchFlow/upload"] forSource:self.downloadedLocation];
    NSURLSessionUploadTask *uploadTask = [self.ephemeralSession uploadTaskWithRequest:[uploadHelper requestWithHeader] fromData:[uploadHelper requestHTTPBody] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"Got response %@ with error %@.\n", response, error);
        NSLog(@"DATA:\n%@\nEND DATA\n",
              [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
    [uploadTask resume];
}

#pragma mark delegate implementation


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Session %@ download task %@ finished downloaidng to Location URL:%@", session, downloadTask, location);
    
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.downloadedLocation path]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self.downloadedLocation path] error:nil];
    }
    if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:self.downloadedLocation error:&error])
    {
        NSLog(@"Failed to save file from %@ to %@ with error %@", location, self.downloadedLocation, error);
    }
    else
    {
        NSLog(@"Moved file to %@ Successfully", self.downloadedLocation);
    }
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error %@ %@", error, [error userInfo]);
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"total sent %li, written %li, expected %li", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Received response %@", response);
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"Session %@ Task %@ completed with Error %@", session, task, error);
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
      NSLog(@"total sent %lli, written %lli, expected %lli", bytesSent, totalBytesSent, totalBytesExpectedToSend);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
