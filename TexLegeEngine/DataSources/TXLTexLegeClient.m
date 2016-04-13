//
//  TXLTexLegeClient.m
//  TexLege
//
//  Created by Gregory Combs on 3/30/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLTexLegeClient.h"
#import "TXLConstants.h"
#import "TXLDataConversion.h"
#import "TXLLegislator.h"
#import "TXLAggregatePartisanScore.h"
#import "TXLCommittee.h"
#import "TXLPartisanScore.h"
#import "TXLStaffer.h"
#import "TXLReachability.h"

@implementation TXLTexLegeClient

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (self)
    {
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:TXLPrivateConfig.texlegeUser
                                                               password:TXLPrivateConfig.texlegePassword];

        TXLReachability *reachability = [TXLReachability sharedManager];
        self.reachabilityManager = reachability;

        __weak typeof(self) weakSelf = self;
        [reachability setTexLegeReachabilityStatusChangeBlock: ^(AFNetworkReachabilityStatus status) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf)
                return;

            if (status == AFNetworkReachabilityStatusNotReachable)
                strongSelf.operationQueue.suspended = YES;
            else if (status == AFNetworkReachabilityStatusReachableViaWiFi ||
                     status == AFNetworkReachabilityStatusReachableViaWWAN)
            {
                strongSelf.operationQueue.suspended = NO;
            }
        }];

        if (reachability.isReachable)
            self.operationQueue.suspended = NO;

        [self setDataTaskWillCacheResponseBlock: ^NSCachedURLResponse *(NSURLSession *session,
                                                                        NSURLSessionDataTask *dataTask,
                                                                        NSCachedURLResponse *proposedResponse)
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)[proposedResponse response];
            if ([session configuration].requestCachePolicy == NSURLRequestUseProtocolCachePolicy &&
                (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299))
            {
                NSDictionary *headers = [httpResponse allHeaderFields];
                NSString *cacheControl = headers[@"Cache-Control"];
                NSString *expires = headers[@"Expires"];
                if ((cacheControl == nil) && (expires == nil))
                {
                    NSMutableDictionary *modifiedHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
                    modifiedHeaders[@"Cache-Control"] = @"max-age=3600";
                    NSDictionary *userInfo = @{@"cachedDate": [NSDate date]};

                    NSHTTPURLResponse *modifiedResponse = [[NSHTTPURLResponse alloc] initWithURL:httpResponse.URL
                                                                                      statusCode:httpResponse.statusCode
                                                                                     HTTPVersion:@"HTTP/1.1"
                                                                                    headerFields:modifiedHeaders];

                    NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:modifiedResponse
                                                                                                   data:proposedResponse.data
                                                                                               userInfo:userInfo
                                                                                          storagePolicy:proposedResponse.storagePolicy];
                    return cachedResponse;
                }
            }
            return proposedResponse;
        }];

    }
    return self;
}

- (instancetype)init
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

    sessionConfig.HTTPShouldUsePipelining = YES;
    sessionConfig.timeoutIntervalForRequest = 90;
    sessionConfig.timeoutIntervalForResource = 90;
    sessionConfig.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain;

    NSURL *url = [NSURL URLWithString:TXLPrivateConfig.texlegeBaseURL];
    self = [self initWithBaseURL:url sessionConfiguration:sessionConfig];
    return self;
}

+ (NSDictionary *)modelClassesByResourcePath
{
    return @{
             @"committees/**": [TXLCommittee class],
             @"committees": [TXLCommittee class],
             @"legislators/**": [TXLLegislator class],
             @"legislators": [TXLLegislator class],
             @"staffers/**": [TXLStaffer class],
             @"staffers": [TXLStaffer class],
             @"partsianScores/**": [TXLPartisanScore class],
             @"partisanScores": [TXLPartisanScore class],
             @"aggregatePartsianScores/**": [TXLAggregatePartisanScore class],
             @"aggregatePartsianScores": [TXLAggregatePartisanScore class],
             };
}

- (RACSignal *)fetchLegislators
{
    return [[self rac_GET:@"legislators" parameters:nil] map:^id(OVCResponse *response) {
        return TXLMapListResponseToDictWithKey(response, @"legId");
    }];
}

- (RACSignal *)fetchCommittees
{
    return [[self rac_GET:@"committees" parameters:nil] map:^id(OVCResponse *response) {
        return TXLMapListResponseToDictWithKey(response, @"committeeId");
    }];
}

- (RACSignal *)fetchStaffers
{
    return [[self rac_GET:@"staffers" parameters:nil] map:^id(OVCResponse *response) {
        return TXLMapListResponseToGroupedDictWithKey(response, @"legId");
    }];
}

- (RACSignal *)fetchPartisanScores
{
    return [[self rac_GET:@"partisanScores" parameters:nil] map:^id(OVCResponse *response) {
        return TXLMapListResponseToGroupedDictWithKey(response, @"legId");
    }];
}

- (RACSignal *)fetchAggregatePartisanScores
{
    return [[self rac_GET:@"aggregatePartsianScores" parameters:nil] map:^id(OVCResponse *response) {
        return TXLMapListResponseToGroupedDictWithNestedKeys(response, @"chamber", @"partyId");
    }];
}

@end
