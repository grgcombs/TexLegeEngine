//
//  TXLDataModelCombinatorTests.m
//  TexLege
//
//  Created by Gregory Combs on 4/8/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import UIKit;
@import XCTest;
@import Asterism;
#import "TXLOpenStatesClient.h"
#import "TXLTexLegeClient.h"
#import "TXLDataModelCombinator.h"
#import "TXLLegislator.h"
#import "TXLCommittee.h"

@interface TXLDataModelCombinatorTests : XCTestCase

@property (nonatomic,copy) NSDictionary *txLegislatorJSON;
@property (nonatomic,copy) NSDictionary *osLegislatorJSON;
@property (nonatomic,strong) TXLOpenStatesClient *osClient;
@property (nonatomic,strong) TXLTexLegeClient *txClient;

@end

@implementation TXLDataModelCombinatorTests

- (void)setUp
{
    [super setUp];

    _txLegislatorJSON = @{
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

    _osLegislatorJSON = @{
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

- (void)testCombineSingleLegislatorPair
{
    NSError *error = nil;
    TXLLegislator *txLegislator = [MTLJSONAdapter modelOfClass:[TXLLegislator class] fromJSONDictionary:_txLegislatorJSON error:&error];
    XCTAssertNil(error, @"Should be able to map a TexLege server legislator to the TXLLegislator class");
    XCTAssertTrue([txLegislator isKindOfClass:[TXLLegislator class]], @"Should be able to map a TexLege server legislator to the TXLLegislator class");

    TXLLegislator *osLegislator = [MTLJSONAdapter modelOfClass:[TXLLegislator class] fromJSONDictionary:_osLegislatorJSON error:&error];
    XCTAssertNil(error, @"Should be able to map an OpenStates legislator to the TXLLegislator class");
    XCTAssertTrue([osLegislator isKindOfClass:[TXLLegislator class]], @"Should be able to map an OpenStates legislator to the TXLLegislator class");

    TXLLegislator *merged = osLegislator;
    [merged mergeValuesForKeysFromModel:txLegislator excludingKeys:@[@"legId"]];
    XCTAssertNotNil(merged, @"Should still have a legislator model object after merging");

    XCTAssertEqualObjects(merged.chamber, @"upper", @"Merged chamber should remain as before");
    XCTAssertTrue(merged.roles.count == 1, @"Should still have 1 role for the merged legislator model");
    XCTAssertEqualWithAccuracy(merged.partisanIndex.doubleValue, -0.8291, 0.01, @"Should have a correct partisanIndex after the merge");

    NSURL *largePhotoURL = [NSURL URLWithString:_txLegislatorJSON[@"photo_url"]];
    XCTAssertNotNil(TXLTypeURLOrNil(merged.photoUrl), @"Merged legislator should have a correctly mapped URL value");
    XCTAssertEqualObjects(merged.photoUrl, largePhotoURL, @"Merged legislator should have the 'new' value in the event of conflicting keys.");
}

- (void)testFetchAndCombineLegislators
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch and Combine Legislators"];

    if (!_txClient)
        _txClient = [[TXLTexLegeClient alloc] init];
    if (!_osClient)
        _osClient = [[TXLOpenStatesClient alloc] init];

    RACSignal *compositeLegislators = [TXLDataModelCombinator mergeModelsFromSignals:[_osClient fetchLegislators]
                                                                                 and:[_txClient fetchLegislators]
                                                                       excludingKeys:@[@"legId"]];

    [compositeLegislators subscribeNext:^(NSDictionary *legislators)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(legislators), @"Expected non-empty dictionary of legislator results");
         XCTAssertEqual((int)legislators.count,182, @"Expected 182 legislators.");

         TXLLegislator *found = ASTFind(legislators, ^BOOL(TXLLegislator *obj) {
             if (obj.email && [obj.email isEqualToString:@"judith.zaffirini@senate.state.tx.us"])
                 return YES;
             return NO;
         });
         XCTAssertNotNil(found, @"Should have found Judith Zaffirini by email");

         NSArray *offices = TXLTypeNonEmptyArrayOrNil(found.offices);
         XCTAssertNotNil(offices, @"Should have offices array from OpenStates");

         NSArray *roles = TXLTypeNonEmptyArrayOrNil(found.roles);
         XCTAssertNotNil(roles, @"Should have roles array from OpenStates");

         XCTAssertEqualObjects(found.party, @"Democratic", @"Zaffirini's party is Democratic");

         XCTAssertEqual(found.chamberId, TXLMetadataChamberUpper, @"Zaffirini is a state senator");

         XCTAssertLessThan(found.partisanIndex.doubleValue, -0.50, @"Zaffirini's partisanship should be more 'left' than average");

     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching legislators: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:8 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch legislators failed with error: %@", error);
    }];
}

- (void)testFetchAndCombineCommittees
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Test Fetch and Combine Committees"];

    if (!_txClient)
        _txClient = [[TXLTexLegeClient alloc] init];
    if (!_osClient)
        _osClient = [[TXLOpenStatesClient alloc] init];

    RACSignal *compositeCommittees = [TXLDataModelCombinator mergeModelsFromSignals:[_osClient fetchCommittees]
                                                                                and:[_txClient fetchCommittees]
                                                                      excludingKeys:@[@"committeeId"]];

    [compositeCommittees subscribeNext:^(NSDictionary *committees)
     {
         XCTAssertNotNil(TXLTypeDictionaryOrNil(committees), @"Expected non-empty dictionary of committee results");
         XCTAssertGreaterThan((int)committees.count,20, @"Expected at least 20 committees.");

         TXLCommittee *found = ASTFind(committees, ^BOOL(TXLCommittee *obj) {
             if (obj.name && [obj.name isEqualToString:@"Calendars"])
                 return YES;
             return NO;
         });
         XCTAssertNotNil(found, @"Should have found a 'Calendars' committee");

         NSArray *members = TXLTypeNonEmptyArrayOrNil(found.members);
         XCTAssertNotNil(members, @"Should have an array of members for the committee: %@", found.name);

         NSURL *url = TXLTypeURLOrNil(found.url);
         XCTAssertNotNil(url, @"Should have a URL for the committee: %@", found.name);

     } error:^(NSError *error) {
         XCTFail(@"Encountered error fetching committees: %@", error);
     } completed:^{
         [expectation fulfill];
     }];

    [self waitForExpectationsWithTimeout:8 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Fetch committees failed with error: %@", error);
    }];
}

@end
