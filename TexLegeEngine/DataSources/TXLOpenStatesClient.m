//
//  TXLOpenStatesClient.m
//  TexLege
//
//  Created by Gregory Combs on 3/30/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLOpenStatesClient.h"
#import "TXLConstants.h"
#import "TXLDataConversion.h"
#import "TXLCommittee.h"
#import "TXLLegislator.h"
#import "TXLMetadata.h"
#import "TXLReachability.h"
#import "TexLegeEngine.h"

@import Asterism;

@import ReactiveCocoa;

@interface TXLOpenStatesClient ()
@property (nonatomic,strong) NSURLSessionDataTask *dataTask;
@property (atomic,assign) TXLPrivateConfigType clientConfig;
+ (NSArray *)defaultLegislatorFields;
+ (NSArray *)defaultCommitteeFields;
@end

@implementation TXLOpenStatesClient

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfig:(NSURLSessionConfiguration *)sessionConfig clientConfig:(TXLPrivateConfigType)clientConfig
{
    if (!TXLPrivateConfigIsValid(clientConfig))
        return nil;

    self = [super initWithBaseURL:url sessionConfiguration:sessionConfig];
    if (self)
    {
        _clientConfig = clientConfig;

        [self.requestSerializer setValue:clientConfig.sunlightApiKey forHTTPHeaderField:@"X-APIKEY"];

        TXLReachability *reachability = [TXLReachability sharedManager];
        self.reachabilityManager = reachability;

        __weak typeof(self) weakSelf = self;
        [reachability setOpenStatesReachabilityStatusChangeBlock: ^(AFNetworkReachabilityStatus status) {
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

    TexLegeEngine *engine = [TexLegeEngine instance];
    TXLPrivateConfigType clientConfig = engine.privateConfig;

    self = [self initWithBaseURL:TXLOpenStatesBaseURL sessionConfig:sessionConfig clientConfig:clientConfig];
    return self;
}

+ (NSDictionary *)modelClassesByResourcePath {
    return @{
             @"committees/**": [TXLCommittee class],
             @"committees": [TXLCommittee class],
             @"legislators/**": [TXLLegislator class],
             @"legislators": [TXLLegislator class],
             @"metadata/**": [TXLMetadata class],
             };
}

- (RACSignal *)fetchStateMetadata
{
    NSDictionary *parameters = @{@"apikey": _clientConfig.sunlightApiKey};
    NSString *path = [@"metadata" stringByAppendingPathComponent:TXLCommonConfig.openstatesStateId];
    return [[self rac_GET:path parameters:parameters] map:^id(OVCResponse *response) {
        return TXLMapValidDetailsResponseToClass(response,TXLMetadata);
    }];
}

- (RACSignal *)fetchCommittees
{
    NSString *fields = [[[self class] defaultCommitteeFields] componentsJoinedByString:@","];
    NSDictionary *parameters = @{
                                 @"apikey": _clientConfig.sunlightApiKey,
                                 @"state": TXLCommonConfig.openstatesStateId,
                                 @"fields": fields,
                                 };

    return [[self rac_GET:@"committees" parameters:parameters] map:^id(OVCResponse *response) {
        return TXLMapListResponseToDictWithKey(response, @"committeeId");
    }];
}

- (RACSignal *)fetchEvents
{
    NSDictionary *parameters = @{
                                 @"apikey": _clientConfig.sunlightApiKey,
                                 @"stateId": TXLCommonConfig.openstatesStateId
                                 };

    return [[self rac_GET:@"events/" parameters:parameters] map:^id(OVCResponse *response) {
        return TXLMapListResponseToDictWithKey(response, @"id");
    }];
}

- (RACSignal *)fetchBillsWithParameters:(NSDictionary *)parameters
{
    if (!TXLTypeNonEmptyStringOrNil(parameters))
        return nil;
    NSMutableDictionary *completeParams = [parameters mutableCopy];
    if (!completeParams[@"search_window"])
        completeParams[@"search_window"] = @"session";
    completeParams[@"state"] = TXLCommonConfig.openstatesStateId;
    completeParams[@"apikey"] = _clientConfig.sunlightApiKey;

    return [[self rac_GET:@"bills" parameters:parameters] map:^id(OVCResponse *response) {
        return TXLMapListResponseToDictWithKey(response, @"id");
    }];
}

- (RACSignal *)fetchBillWithIdentifier:(NSString *)identifier
{
    if (!TXLTypeNonEmptyStringOrNil(identifier))
        return nil;
    NSString *path = [@"bills" stringByAppendingPathComponent:identifier];
    NSDictionary *parameters = @{@"apikey": _clientConfig.sunlightApiKey};
    return [[self rac_GET:path parameters:parameters] map:^id(OVCResponse *response) {
        return TXLMapValidDetailsResponseToClass(response,NSDictionary);
    }];
}

- (RACSignal *)fetchLegislators
{
    NSString *fields = [[[self class] defaultLegislatorFields] componentsJoinedByString:@","];

    NSDictionary *parameters = @{
                                 @"apikey": _clientConfig.sunlightApiKey,
                                 @"state": TXLCommonConfig.openstatesStateId,
                                 @"fields": fields,
                                 };

    return [[self rac_GET:@"legislators" parameters:parameters] map:^id(OVCResponse *response) {
        return TXLMapListResponseToDictWithKey(response, @"legId");
    }];
}

- (RACSignal *)fetchLegislatorsForCoordinates:(CLLocationCoordinate2D)coordiates
{
    if (!CLLocationCoordinate2DIsValid(coordiates))
        return nil;

    NSString *fields = [[[self class] defaultLegislatorFields] componentsJoinedByString:@","];

    NSDictionary *parameters = @{
                                 @"lat": @(coordiates.latitude),
                                 @"long": @(coordiates.longitude),
                                 @"apikey": _clientConfig.sunlightApiKey,
                                 @"fields": fields,
                                 };
    return [[self rac_GET:@"legislators/geo" parameters:parameters] map:^id(OVCResponse *response) {
        return TXLMapListResponseToDictWithKey(response, @"legId");
    }];
}

- (RACSignal *)fetchDistricts
{
    NSString *path = [@"districts" stringByAppendingPathComponent:TXLCommonConfig.openstatesStateId];
    NSDictionary *parameters = @{@"apikey": _clientConfig.sunlightApiKey};
    return [[self rac_GET:path parameters:parameters] map:^id(OVCResponse *response) {
        return TXLMapListResponseToDictWithKey(response, @"boundary_id");
    }];
}

- (RACSignal *)fetchDistrictMapforChamber:(NSString *)chamber district:(NSString *)district
{
    if (!TXLTypeNonEmptyStringOrNil(chamber) || !TXLTypeNonEmptyStringOrNil(district))
        return [RACSignal empty];

    NSString *path = [@"districts" stringByAppendingPathComponent:TXLCommonConfig.openstatesStateId];
    NSDictionary *parameters = @{@"apikey": _clientConfig.sunlightApiKey,
                                 @"chamber": chamber};

    __weak typeof(self) bself = self;
    return  [[[self rac_GET:path parameters:parameters] map:^id(OVCResponse *response) {
        NSArray *items = TXLTypeNonEmptyArrayOrNil((NSArray *)response.result);
        if (!items)
            return nil;
        NSDictionary *item = ASTFind(items, ^BOOL(id obj, NSUInteger idx) {
            NSDictionary *mapInfo = TXLTypeDictionaryOrNil(obj);
            return [TXLTypeNonEmptyStringOrNil(mapInfo[@"name"]) isEqualToString:district];
        });
        if (!item)
            return nil;
        return TXLTypeNonEmptyStringOrNil(item[@"boundary_id"]);
    }] flattenMap:^RACStream *(NSString *boundaryId) {
        if (!boundaryId)
            return nil;
        return [bself fetchDistrictMapWithIdentifier:boundaryId];
    }];
}

- (RACSignal *)fetchDistrictMapWithIdentifier:(NSString *)identifier
{
    if (!TXLTypeNonEmptyStringOrNil(identifier))
        return nil;
    NSString *path = [@"districts/boundary" stringByAppendingPathComponent:identifier];
    NSDictionary *parameters = @{@"apikey": _clientConfig.sunlightApiKey};
    return [[self rac_GET:path parameters:parameters] map:^id(OVCResponse *response) {
        return TXLMapValidDetailsResponseToClass(response,NSDictionary);
    }];
}

#pragma mark - Class Constants

+ (NSArray *)defaultLegislatorFields
{
    static NSArray * kOpenStatesLegislatorFields = nil;
    if (!kOpenStatesLegislatorFields.count)
        kOpenStatesLegislatorFields = @[
                                        @"_all_ids",
                                        @"+birth_date",
                                        @"+capital_address",
                                        @"+district_address",
                                        @"active",
                                        @"boundary_id",
                                        @"chamber",
                                        @"created_at",
                                        @"district",
                                        @"first_name",
                                        @"full_name",
                                        @"id",
                                        @"last_name",
                                        @"leg_id",
                                        @"middle_name",
                                        @"nickname",
                                        @"nimsp_candidate_id",
                                        @"nimsp_id",
                                        @"offices",
                                        @"party",
                                        @"photo_url",
                                        @"roles",
                                        @"suffixes",
                                        @"transparencydata_id",
                                        @"updated_at",
                                        @"url",
                                        @"votesmart_id",
                                        ];
    return kOpenStatesLegislatorFields;
}

+ (NSArray *)defaultCommitteeFields
{
    static NSArray * kOpenStatesCommitteeFields = nil;
    if (!kOpenStatesCommitteeFields.count)
        kOpenStatesCommitteeFields = @[
                                       @"_all_ids",
                                       @"chamber",
                                       @"committee",
                                       @"created_at",
                                       @"id",
                                       @"members",
                                       @"parent_id",
                                       @"subcommittee",
                                       @"updated_at",
                                       ];
    return kOpenStatesCommitteeFields;
}

@end
