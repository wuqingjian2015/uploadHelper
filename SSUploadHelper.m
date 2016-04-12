//
//  SSUploadHelper.m
//  OHCardToolApp
//
//  Created by caoli on 16/4/11.
//  Copyright © 2016年 QingjianWu. All rights reserved.
//

#import "SSUploadHelper.h"
@interface SSUploadHelper()

@property (nonatomic, strong) NSString* boundary;
@property (nonatomic, strong) NSString* beginBoundary;
@property (nonatomic, strong) NSString* endBoundary;



@property (nonatomic, assign) BOOL changedFlag;

@end

static NSString* beginBoundaryFormat = @"--%@\r\n";
static NSString* endBoundaryFormat = @"\r\n--%@--\r\n";
@implementation SSUploadHelper

@synthesize sourceURL = _sourceURL;
@synthesize targetURL = _targetURL;
@synthesize boundary = _boundary;

-(instancetype)initWithTarget:(NSURL*)target forSource:(NSURL*)source
{
    self = [super init];
    if (self) {
        _changedFlag = YES;
        _sourceURL = source;
        _targetURL = target;

    }
    return self;
}

-(NSURL*)targetURL
{
    return _targetURL;
}
-(void)setTargetURL:(NSURL *)targetURL
{
    _targetURL = targetURL;
    self.changedFlag = YES;
}

-(NSURL*) sourceURL
{
    return _sourceURL;
}

-(void) setSourceURL:(NSURL *)sourceURL
{
    _sourceURL = sourceURL;
    self.changedFlag = YES;
}

-(NSString *)boundary
{
    if(self.changedFlag && !_boundary){
        _boundary =[NSString stringWithFormat:@"--KenApp%lli", arc4random() % INT64_MAX];
    }
    return _boundary;
}
-(void)setBoundary:(NSString *)boundary
{
    _boundary = boundary;
}

-(NSString*)beginBoundary
{
    if (!_beginBoundary) {
        _beginBoundary = [NSString stringWithFormat:beginBoundaryFormat, self.boundary];
    }
    return _beginBoundary;
}

-(NSString*) endBoundary
{
    if (!_endBoundary) {
        _endBoundary = [NSString stringWithFormat:endBoundaryFormat, self.boundary];
    }
    return _endBoundary;
}

-(NSData*)requestHTTPBody
{
    if (self.changedFlag && !_requestHTTPBody) {
        _requestHTTPBody = [self createDataForRequestHTTPBodyForSource];
      //  self.changedFlag = NO;
    }
    return _requestHTTPBody;
}

-(NSURLRequest*)requestWithHeader
{
    if (self.changedFlag && !_requestWithHeader) {
        _requestWithHeader = [self createRequestHeader];
        //self.changedFlag = NO;
    }
    return _requestWithHeader;
}
-(NSURLRequest *)createRequestHeader
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.targetURL];
    
    //创建http header请求标头内容
    //  Content-Type := multipart/form-data; boundary=---------------827292(任意)
    //  Content-Length := (文件长度)

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"post"];
    //创建NSURLRequest并配置请求头，请求体
    return request;
}

-(NSURLRequest*) requestWithHeaderAndBody
{
    if (self.changedFlag && !_requestWithHeaderAndBody) {
        NSMutableURLRequest* request = [[self requestWithHeader] mutableCopy];
        NSData*  headBody = [self requestHTTPBody];
        
        [request setHTTPBody:headBody];
        _requestWithHeaderAndBody = request;
    }
  
    return _requestWithHeaderAndBody;
}

-(NSData*)createDataForRequestHTTPBodyForSource
{
    NSMutableString *bodyHead = [[NSMutableString alloc] init];
    NSMutableData *data = [[NSMutableData alloc] init];
    
    NSString *fileName = [self.sourceURL lastPathComponent];
    NSString *name=@"uploadFile";
    
    NSData *fileContent = [NSData dataWithContentsOfURL:self.sourceURL];
    //创建http body请求体内容
    //  第一行： --827292
    [bodyHead appendString:self.beginBoundary];
    // [body appendFormat:@"--------------------"]
    //  Content-Disposition: form-data; name="uploadFile"; filename="xxxx.ext"
    [bodyHead appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",name,fileName];
    //  Content-Type: application/x-zip-compressed
    //  (空行)
    [bodyHead appendFormat:@"Content-Type: application/zip\r\n\r\n"];
    //  (二进制数据）
    [data appendData:[bodyHead dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:fileContent];
    //  最后一行：827292--
    
    [data appendData:[self.endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
}

@end
