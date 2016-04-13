//
//  TXLOpenStatesClient.h
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
#import "TXLConstants.h"

@interface TXLOpenStatesClient : OVCHTTPSessionManager

- (instancetype)init;

/**
 *  A signal to fetch the common metadata for the state legislature.
 *
 *  @return A reactive signal for the fetch request.
 */
- (RACSignal *)fetchStateMetadata;

/**
 *  A signal to fetch the basic information for the legislative committees.
 *
 *  @return A reactive signal for the fetch request.
 */
- (RACSignal *)fetchCommittees;

/**
 *  A signal to fetch information on legislative events such as committee meetings.
 *
 *  @return A reactive signal for the fetch request.
 */
- (RACSignal *)fetchEvents;

/**
 *  A signal to fetch legislator information, including roles, all_ids, offices, etc.
 *
 *  @return A reactive signal for the fetch request.
 */
- (RACSignal *)fetchLegislators;

/**
 *  A signal to find the legislators corresponding to a given coordinate on the map.
 *
 *  @param coordiates A latitude/longitude coordinate on the (Texas) map.
 *
 *  @return A reactive signal that will return the found legislators.
 */
- (RACSignal *)fetchLegislatorsForCoordinates:(CLLocationCoordinate2D)coordiates;

- (RACSignal *)fetchDistricts;
- (RACSignal *)fetchDistrictMapWithIdentifier:(NSString *)identifier;
- (RACSignal *)fetchDistrictMapforChamber:(NSString *)chamber district:(NSString *)district;

- (RACSignal *)fetchBillsWithParameters:(NSDictionary *)parameters;
- (RACSignal *)fetchBillWithIdentifier:(NSString *)identifier;

@end
