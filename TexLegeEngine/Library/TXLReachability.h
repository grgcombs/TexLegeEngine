//
//  TXLReachability.h
//  TexLege
//
//  Created by Gregory Combs on 4/7/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import Foundation;
@import AFNetworking.AFNetworkReachabilityManager;

@interface TXLReachability : AFNetworkReachabilityManager

+ (instancetype)sharedManager;

- (void)startMonitoring;

- (void)stopMonitoring;

@property (nonatomic,assign,readonly,getter=isMonitoring) BOOL monitoring;

- (void)setTexLegeReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block;

- (void)setOpenStatesReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block;

@end

extern NSString * const TXLReachabilityStatusDidChange;

