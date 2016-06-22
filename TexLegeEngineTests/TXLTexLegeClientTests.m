//
//  TXLTexLegeClientTests.m
//  TexLege
//
//  Created by Gregory Combs on 3/31/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import XCTest;
@import Overcoat;
@import ReactiveCocoa;
@import CoreLocation;
#import "TXLTexLegeClient.h"
#import "TXLReachability.h"
#import "TXLConstants.h"
#import "TXLLegislator.h"
#import "TexLegeEngine.h"

@interface TXLTexLegeClientTests : XCTestCase

@property (nonatomic,strong) TXLTexLegeClient *client;
@property (nonatomic,copy) NSDictionary *legislatorJSON;

@end

@implementation TXLTexLegeClientTests

- (void)setUp
{
    [super setUp];

    [TexLegeEngine instanceWithPrivateConfig:TXLPrivateConfigProduction];

    _legislatorJSON = @{
                        @"bio_url": @"http://votesmart.org/candidate/biography/5465",
                        @"cap_fax": @"(512) 475-3738",
                        @"cap_office": @"1E.14",
                        @"cap_phone": @"(512) 463-0121",
                        @"chamber": @"upper",
                        @"district": @"21",
                        @"email": @"judith.zaffirini@senate.state.tx.us",
                        @"first_name": @"Judith",
                        @"last_initial": @"Z",
                        @"last_name": @"Zaffirini",
                        @"leg_id": @"TXL000213",
                        @"partisan_index": @(-0.8291),
                        @"party_id": @1,
                        @"photo_url": @"http://www.legdir.legis.state.tx.us/FlashCardDocs/images/Senate/large/A1700.jpg",
                        @"preferred_name": @"Judith",
                        @"twitter": @"@JudithZaffirini",
                        @"txlonline_id": @"A1700",
                        @"updated_at": @"2015-01-19 16:51:59",
                        @"votesmart_id": @"5465"
                        };    
}

- (void)tearDown
{
    [_client invalidateSessionCancelingTasks:YES];
    _client = nil;
    [super tearDown];
}

- (void)testClientInstantiates
{
    TXLTexLegeClient *client = [[TXLTexLegeClient alloc] init];
    XCTAssertNotNil(client, @"Client failed to instantiate");
    if (!_client)
        _client = client;
}

- (void)testAccuracyOfRelativeURLs
{
    if (!_client)
        _client = [[TXLTexLegeClient alloc] init];
    NSURL *baseURL = _client.baseURL;
    XCTAssertNotNil(baseURL, @"Expected a valid base URL.");

    NSString *relativePath = @"relative/path";
    NSURL *relativeURL = [NSURL URLWithString:relativePath relativeToURL:baseURL];
    XCTAssertNotNil(relativeURL, @"Expected a valid relative URL.");

    TXLPrivateConfigType privateConfig = [TexLegeEngine instance].privateConfig;
    NSString *expected = [privateConfig.texlegeBaseURL stringByAppendingString:relativePath];
    XCTAssertEqualObjects(relativeURL.absoluteString, expected, @"Failed to make full URL from relative path.");
}


- (void)testServerIsReachable
{
    TXLReachability *reachability = [TXLReachability sharedManager];
    XCTAssertNotNil(reachability, @"Expected a valid reachability manager.");

    if (reachability.isReachable)
    {
        XCTestExpectation *expectation = [self expectationWithDescription:@"Test Network Reachability"];
        [expectation fulfill];
    }
    else
    {
        @weakify(self);
        [self expectationForNotification:TXLReachabilityStatusDidChange object:nil handler:^BOOL(NSNotification *notification)
        {
            @strongify(self);
            if (!self || !notification.userInfo)
                return NO;
            NSNumber *statusValue = notification.userInfo[AFNetworkingReachabilityNotificationStatusItem];
            if (!statusValue)
                return NO;
            AFNetworkReachabilityStatus status = (AFNetworkReachabilityStatus)statusValue.integerValue;
            return (status == AFNetworkReachabilityStatusReachableViaWiFi ||
                    status == AFNetworkReachabilityStatusReachableViaWWAN);
        }];
    }

    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Failed Network reachability: %@", error);
    }];
}

- (void)testFetchLegislators
{
    if (!_client)
        _client = [[TXLTexLegeClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch Legislators"];

    [[_client fetchLegislators] subscribeNext:^(NSDictionary *legislators)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(legislators), @"Expected non-empty dictionary of legislator results");
         XCTAssertEqual((int)legislators.count,182, @"Expected 182 legislators.");
     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching legislators: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:6 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch legislators failed with error: %@", error);
    }];
}

- (void)testLegislatorConvenienceProperties
{

    NSDictionary *input = @{
                            @"chamber": @"lower",
                            @"leg_id": @"TXL000215",
                            @"partisan_index": @(-0.7468),
                            @"party_id": @1,
                            @"updated_at": @"2015-01-19 16:58:47",
                            @"url": @"http://www.house.state.tx.us/",
                            };

    NSError *error = nil;
    TXLLegislator *output = [MTLJSONAdapter modelOfClass:[TXLLegislator class] fromJSONDictionary:input error:&error];
    XCTAssertNil(error, @"Error while mapping legislator response");

    XCTAssertNotNil(output, @"Unable to map a legislator response to a legislator model");
    XCTAssertTrue([output isKindOfClass:[TXLLegislator class]], @"Unexpected model class for legislator response");
    XCTAssertEqual(output.chamberId, TXLMetadataChamberLower, @"Chamber ID doesn't match");
    XCTAssertEqual(output.partyId, TXLLegislatorDemocratParty, @"Party ID doesn't match");
    XCTAssertNotNil(TXLTypeDateOrNil(output.updatedAt), @"Expected a valid updatedAt date value");
    XCTAssertNotNil(TXLTypeURLOrNil(output.url), @"Expected a valid URL value");
}


- (void)testFetchStaffers
{
    if (!_client)
        _client = [[TXLTexLegeClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch Staffers"];

    [[_client fetchStaffers] subscribeNext:^(NSDictionary *stafferMap)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(stafferMap), @"Expected non-empty dictionary of staffer results");
         XCTAssertGreaterThan((int)stafferMap.count, 100, @"Expected at least a hundred groups of staffers (by legislator ID)");

         __block BOOL hasArrayOfStaffers = NO;
         [stafferMap enumerateKeysAndObjectsUsingBlock:^(NSString *legId, NSArray *staffers, BOOL *stop) {
             hasArrayOfStaffers = (TXLTypeNonEmptyArrayOrNil(staffers) != NULL);
             *stop = YES;
         }];
         XCTAssertTrue(hasArrayOfStaffers, @"Expected the staffer map to have arrays of staffers mapped by legislator ID");
     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching staffers: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:6 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch staffers failed with error: %@", error);
    }];
}

- (void)testFetchPartisanScores
{
    if (!_client)
        _client = [[TXLTexLegeClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch Partisan Scores"];

    [[_client fetchPartisanScores] subscribeNext:^(NSDictionary *scoreMap)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(scoreMap), @"Expected non-empty dictionary of score results");
         XCTAssertGreaterThan((int)scoreMap.count, 100, @"Expected at least a hundred groups of scores (by legislator ID)");

         __block BOOL hasArrayOfScores = NO;
         [scoreMap enumerateKeysAndObjectsUsingBlock:^(NSString *legId, NSArray *scores, BOOL *stop) {
             hasArrayOfScores = (TXLTypeNonEmptyArrayOrNil(scores) != NULL);
             *stop = YES;
         }];
         XCTAssertTrue(hasArrayOfScores, @"Expected the scores map to have arrays of scores mapped by legislator ID");
     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching partisan scores: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:6 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch partisan scores failed with error: %@", error);
    }];
}

- (void)testFetchAggregatePartisanScores
{
    if (!_client)
        _client = [[TXLTexLegeClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch Aggregate Partisan Scores"];

    [[_client fetchAggregatePartisanScores] subscribeNext:^(NSDictionary *scoreMap)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(scoreMap), @"Expected non-empty dictionary of score results");
         XCTAssertEqual((int)scoreMap.count, 2, @"Expected the aggregate score map to have exactly two keys");

         NSArray *validPartyIds = @[@1,@2];
         NSArray *validChambers = @[@"upper",@"lower"];
         [scoreMap enumerateKeysAndObjectsUsingBlock:^(NSString *chamber, NSDictionary *chamberScores, BOOL *chamberStop) {
             XCTAssertTrue([validChambers containsObject:chamber], @"Found an unexpected chamber type in the score map: %@", chamber);

             XCTAssertNotNil(TXLTypeDictionaryOrNil(chamberScores), @"Expected the aggregate score map to have a dictionary for the chamber: %@", chamber);
             XCTAssertEqual((int)chamberScores.count, 2, @"Expected the chamber scores to have exactly two party keys");

             [chamberScores enumerateKeysAndObjectsUsingBlock:^(NSNumber *partyId, NSArray *scores, BOOL *partyStop) {
                 XCTAssertTrue([validPartyIds containsObject:partyId], @"Found an unexpected party ID in the score map: chamber=%@; party=%@", chamber, partyId);
                 XCTAssertNotNil(TXLTypeNonEmptyArrayOrNil(scores), @"Expected a non-empty array of scores: chamber=%@; party=%@", chamber, partyId);
             }];
         }];
     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching partisan scores: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:6 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch partisan scores failed with error: %@", error);
    }];
}

/*
- (void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

@end
