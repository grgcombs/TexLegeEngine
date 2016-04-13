//
//  TXLReachability.m
//  TexLege
//
//  Created by Gregory Combs on 4/7/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLReachability.h"
#import "TXLConstants.h"
@import SystemConfiguration;
#import <netinet/in.h>
@import ReactiveCocoa;


typedef void (^TXLReachabilityStatusBlock)(AFNetworkReachabilityStatus status);
NSString * const TXLReachabilityStatusDidChange = @"TXLReachabilityStatusDidChange";

@interface TXLReachability ()
@property (readwrite, nonatomic, copy) TXLReachabilityStatusBlock texlegeStatusBlock;
@property (readwrite, nonatomic, copy) TXLReachabilityStatusBlock openstatesStatusBlock;
@property (nonatomic,assign,getter=isMonitoring) BOOL monitoring;
@end

@implementation TXLReachability

+ (instancetype)sharedManager {
    static TXLReachability *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;

        _sharedManager = [self managerForAddress:&address];
    });

    if (!_sharedManager.isMonitoring)
        [_sharedManager startMonitoring];

    return _sharedManager;
}

- (void)startMonitoring
{
    if (self.isMonitoring)
        return;
    self.monitoring = YES;

    @weakify(self);
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self);
        if (!self)
            return;

        if (self.texlegeStatusBlock)
            self.texlegeStatusBlock(status);
        if (self.openstatesStatusBlock)
            self.openstatesStatusBlock(status);

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSDictionary *userInfo = @{ AFNetworkingReachabilityNotificationStatusItem: @(status) };
            [[NSNotificationCenter defaultCenter] postNotificationName:TXLReachabilityStatusDidChange
                                                                object:nil
                                                              userInfo:userInfo];
        }];
    }];

    [super startMonitoring];
}

- (void)stopMonitoring
{
    self.monitoring = NO;
    [super stopMonitoring];
}

- (void)setTexLegeReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus))block
{
    self.texlegeStatusBlock = block;
    if (block && self.isMonitoring)
        block(self.networkReachabilityStatus);
}

- (void)setOpenStatesReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus))block
{
    self.openstatesStatusBlock = block;
    if (block && self.isMonitoring)
        block(self.networkReachabilityStatus);
}

@end
