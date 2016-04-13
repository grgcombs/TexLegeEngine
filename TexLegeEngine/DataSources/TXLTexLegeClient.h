//
//  TXLTexLegeClient.h
//  TexLege
//
//  Created by Gregory Combs on 3/30/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import Foundation;
@import CoreLocation;
@import Overcoat;
@import OvercoatReactiveCocoa;
@import ReactiveCocoa;

@interface TXLTexLegeClient : OVCHTTPSessionManager

- (instancetype)init;

/**
 *  A signal to fetch the legislators, grouped by legislator ID.
 *
 *  @return A reactive signal.
 */
- (RACSignal *)fetchLegislators;

/**
 *  A signal to fetch the legislative staffers, grouped by legislator ID.
 *
 *  @return A reactive signal.
 */
- (RACSignal *)fetchStaffers;

/**
 *  A signal to fetch the legislative partisanship scores, grouped by legislator ID.
 *
 *  @return A reactive signal.
 */
- (RACSignal *)fetchPartisanScores;

/**
 *  A signal to fetch the aggregate partisanship scores, grouped by chamber and then party, sorted by session.
 *
 *  @return A reactive signal.
 */
- (RACSignal *)fetchAggregatePartisanScores;

/**
 *  A signal to fetch the committees, grouped by committee ID.
 *
 *  @return A reactive signal.
 */
- (RACSignal *)fetchCommittees;

/*
- (RACSignal *)fetchLinks;
- (RACSignal *)fetchStateMetadata;
*/

@end
