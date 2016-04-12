//
//  SSUploadHelper.h
//  OHCardToolApp
//
//  Created by caoli on 16/4/11.
//  Copyright © 2016年 QingjianWu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSUploadHelper : NSObject


@property (nonatomic, strong) NSURL* sourceURL;
@property (nonatomic, strong) NSURL* targetURL;

@property (nonatomic, strong) NSData* requestHTTPBody;
@property (nonatomic, strong) NSURLRequest *requestWithHeader;
@property (nonatomic, strong) NSURLRequest *requestWithHeaderAndBody;

-(instancetype)initWithTarget:(NSURL*)target forSource:(NSURL*)source;
@end
