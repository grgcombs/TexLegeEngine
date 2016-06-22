//
//  TXLOpenStatesClientTests.m
//  TexLege
//
//  Created by Gregory Combs on 3/31/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import XCTest;
@import Overcoat;
@import ReactiveCocoa;
@import CoreLocation;
#import "TXLOpenStatesClient.h"
#import "TXLDataConversion.h"
#import "TXLReachability.h"
#import "TXLLegislator.h"
#import "TXLMetadata.h"
#import "TexLegeEngine.h"

@interface TXLOpenStatesClientTests : XCTestCase

@property (nonatomic,strong) TXLOpenStatesClient *client;
@property (nonatomic,copy) NSDictionary *legislatorJSON;
@end

@implementation TXLOpenStatesClientTests

- (void)setUp
{
    [super setUp];

    [TexLegeEngine instanceWithPrivateConfig:TXLPrivateConfigProduction];

    _legislatorJSON = @{
                    @"chamber": @"upper",
                    @"district": @"21",
                    @"first_name": @"Judith",
                    @"full_name": @"Judith Zaffirini",
                    @"last_name": @"Zaffirini",
                    @"leg_id": @"TXL000213",
                    @"transparencydata_id": @"6c110ce2dbd94a24996b13c9e2343fc0",
                    @"updated_at": @"2015-03-25 18:58:39",
                    @"party": @"Democratic",
                    @"photo_url": @"http://www.legdir.legis.state.tx.us/FlashCardDocs/images/Senate/small/A1700.jpg",
                    @"offices": @[@{
                                      @"address": @"P.O. Box 12068, Capitol Station\nAustin, TX 78711",
                                      @"name": @"Capitol address",
                                      @"phone": @"512-463-0121",
                                      @"type": @"capitol"
                                      }],
                    @"roles": @[@{
                                @"chamber": @"upper",
                                @"committee": @"State Affairs",
                                @"committee_id": @"TXC000049",
                                @"position": @"member",
                                @"state": @"tx",
                                @"term": @"84",
                                @"type": @"committee member"
                                }]
                    };
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testClientInstantiates
{
    TXLOpenStatesClient *client = [[TXLOpenStatesClient alloc] init];
    XCTAssertNotNil(client, @"Client failed to instantiate");
    if (!_client)
        _client = client;
}

- (void)testAccuracyOfRelativeURLs
{
    if (!_client)
        _client = [[TXLOpenStatesClient alloc] init];
    NSURL *baseURL = _client.baseURL;
    XCTAssertNotNil(baseURL, @"Expected a valid base URL.");

    NSString *relativePath = @"relative/path";
    NSURL *relativeURL = [NSURL URLWithString:relativePath relativeToURL:baseURL];
    XCTAssertNotNil(relativeURL, @"Expected a valid relative URL.");

    NSString *expected = [TXLCommonConfig.openstatesBaseURL stringByAppendingString:relativePath];
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
            XCTFail(@"Failed TexLege reachability: %@", error);
    }];
}

- (void)testFetchStateMetadata
{
    if (!_client)
        _client = [[TXLOpenStatesClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch State Metadata"];

    [[_client fetchStateMetadata] subscribeNext:^(TXLMetadata *metadata)
     {
         XCTAssertNotNil(metadata, @"Expected non-empty dictionary of state metadata");
         XCTAssertTrue([metadata isKindOfClass:[TXLMetadata class]], @"Unexpected metadata response mapping");
     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching metadata: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:6 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch metadata failed with error: %@", error);
    }];
}

- (void)testFetchLegislators
{
    if (!_client)
        _client = [[TXLOpenStatesClient alloc] init];

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

- (void)testFetchLegislatorsByCoordinates
{
    if (!_client)
        _client = [[TXLOpenStatesClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch Legislators By Coords"];

    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(32.624536,-103.064814);
    [[_client fetchLegislatorsForCoordinates:coords] subscribeNext:^(NSDictionary *legislators)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(legislators), @"Expected non-empty dictionary of legislator results");
         XCTAssertEqual((int)legislators.count,2, @"Expected 2 legislators.");

         __block TXLLegislator *legislator83 = nil;
         __block NSString *boundary83 = nil;
         [legislators enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
             TXLLegislator *legislator = TXLValueIfClass(TXLLegislator,obj);
             if (!legislator)
                 return;
             if ([@"83" isEqual:TXLTypeStringOrNil(legislator.district)])
             {
                 boundary83 = TXLTypeNonEmptyStringOrNil(legislator.boundaryId);
                 legislator83 = legislator;
                 *stop = YES;
             }
         }];
         XCTAssertNotNil(boundary83, @"Expected non-empty boundary ID");
         XCTAssertEqualObjects(boundary83, @"ocd-division/country:us/state:tx/sldl:83", @"Boundary ID for dist. 83 differs");
         XCTAssertNotNil(legislator83, @"Did not find a representative for district 83");
     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching legislators by coords: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:6 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch legislators failed with error: %@", error);
    }];
}

- (void)testFetchCommittees
{
    if (!_client)
        _client = [[TXLOpenStatesClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch Committees"];

    [[_client fetchCommittees] subscribeNext:^(NSDictionary *committees)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(committees), @"Expected non-empty dictionary of committee results");
         XCTAssertGreaterThanOrEqual((int)committees.count,15, @"Expected at least 15 committees.");
     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching committees: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:6 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch committees failed with error: %@", error);
    }];
}

- (void)testFetchEvents
{
    if (!_client)
        _client = [[TXLOpenStatesClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch Events"];

    [[_client fetchEvents] subscribeNext:^(NSDictionary *events)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(events), @"Expected non-empty dictionary of event results");
         XCTAssertGreaterThanOrEqual((int)events.count,1, @"Expected at least 1 event.");
     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching events: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:6 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch events failed with error: %@", error);
    }];
}

- (void)testFetchDistrictMaps
{
    if (!_client)
        _client = [[TXLOpenStatesClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch District Summaries"];

    [[_client fetchDistricts] subscribeNext:^(NSDictionary *districts)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(districts), @"Expected non-empty dictionary of district map results");
         XCTAssertEqual((int)districts.count,181, @"Expected 181 districts.");
     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching district maps: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:8 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch district maps failed with error: %@", error);
    }];
}

- (void)testFetchDistrictMapShapeUsingIdentifier
{
    if (!_client)
        _client = [[TXLOpenStatesClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch District Map Shape (House District 83)"];

    TXLOpenStatesClient *client = _client;

    NSString *boundaryId = @"ocd-division/country:us/state:tx/sldl:83";
    [[client fetchDistrictMapWithIdentifier:boundaryId] subscribeNext:^(NSDictionary *map)
     {

         XCTAssertNotNil(TXLTypeDictionaryOrNil(map), @"Expected non-empty dictionary for House district 83 map shape.");

         NSString *chamber = TXLTypeStringOrNil(map[@"chamber"]);
         XCTAssertEqualObjects(chamber, @"lower", @"Expected lower chamber district map.");

         NSString *identifier = TXLTypeStringOrNil(map[@"id"]);
         XCTAssertEqualObjects(identifier, @"tx-lower-83", @"Expected map for district 83.");

         NSArray *shapes = TXLTypeNonEmptyArrayOrNil(map[@"shape"]);
         XCTAssertEqual((int)shapes.count, 1, @"Expected a shapes array with one contiguous shape.");

         NSArray *boundaryRings = TXLTypeNonEmptyArrayOrNil(shapes[0]);
         XCTAssertEqual((int)boundaryRings.count, 2, @"Expected two boundary rings for House district 83 (one outer, one inner).");

     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching district map: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch House district 83 shape failed with error: %@", error);
    }];
}

- (void)testFetchDistrictMapShapeUsingChamberAndDistrict
{
    if (!_client)
        _client = [[TXLOpenStatesClient alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch District Map Shape (House District 83)"];

    [[_client fetchDistrictMapforChamber:@"lower" district:@"83"] subscribeNext:^(NSDictionary *map)
     {

         XCTAssertNotNil(TXLTypeDictionaryOrNil(map), @"Expected non-empty dictionary for House district 83 map shape.");

         NSString *chamber = TXLTypeStringOrNil(map[@"chamber"]);
         XCTAssertEqualObjects(chamber, @"lower", @"Expected lower chamber district map.");

         NSString *identifier = TXLTypeStringOrNil(map[@"id"]);
         XCTAssertEqualObjects(identifier, @"tx-lower-83", @"Expected map for district 83.");

         NSArray *shapes = TXLTypeNonEmptyArrayOrNil(map[@"shape"]);
         XCTAssertEqual((int)shapes.count, 1, @"Expected a shapes array with one contiguous shape.");

         NSArray *boundaryRings = TXLTypeNonEmptyArrayOrNil(shapes[0]);
         XCTAssertEqual((int)boundaryRings.count, 2, @"Expected two boundary rings for House district 83 (one outer, one inner).");

     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching district map: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch House district 83 shape failed with error: %@", error);
    }];
}

- (void)testLegislatorMappingPerformance
{
    NSDictionary *legislatorJSON = self.legislatorJSON;
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:181];
    for (uint32_t index = 0; index < 181; index++)
        [jsonArray addObject:[legislatorJSON copy]];


    [self measureBlock:^{
        NSError *error = nil;
        NSArray *mappedArray = [MTLJSONAdapter modelsOfClass:[TXLLegislator class] fromJSONArray:jsonArray error:&error];
        XCTAssertNil(error, @"Should have no mapping errors");
        XCTAssertEqual(mappedArray.count, jsonArray.count, @"Should have mapped all the items from the array");

        __block uint32_t index = 0;
        NSDictionary *output = [[mappedArray.rac_sequence foldLeftWithStart:[@{} mutableCopy] reduce:^id(NSMutableDictionary *collection, TXLLegislator *item)
         {
             XCTAssertNotNil(TXLValueIfClass(TXLLegislator,item), @"Expected a legislator item.");
             collection[@(index)] = item;
             index++;
             return collection;
         }] copy];

        XCTAssertEqual(mappedArray.count, output.count, @"Expected the mapped dictionary to be the same size as the mapped array");
    }];
}

@end
