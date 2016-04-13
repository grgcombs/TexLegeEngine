//
//  TXLAggregatePartisanScore.m
//  TexLege
//
//  Created by Gregory Combs on 6/19/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLAggregatePartisanScore.h"
#import "TXLDateUtils.h"

#define txlPropToJSON(KEY,PATH) txlMeta_KEY(TXLAggregatePartisanScore,KEY): PATH

@interface TXLAggregatePartisanScore ()

txlMeta_props_copyrw_def(NSString,aggregateId,chamber);

txlMeta_props_copyrw_def(NSNumber,partyId,session,score);

txlMeta_props_copyrw_def(NSDate,updatedAt);

@end

@implementation TXLAggregatePartisanScore

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             txlPropToJSON(aggregateId,@"aggregate_id"),
             txlPropToJSON(chamber,@"chamber"),
             txlPropToJSON(partyId,@"party_id"),
             txlPropToJSON(session,@"session"),
             txlPropToJSON(score,@"score"),
             txlPropToJSON(updatedAt,@"updated_at"),
             };
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    if (!TXLTypeNonEmptyStringOrNil(key))
        return nil;

    txlMeta_ofks_keys(TXLAggregatePartisanScore,aggregateId,chamber,partyId,session,score,updatedAt);

    txlMeta_ofks_header;

    txlMeta_ofks_footer;
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    txlMeta_soks_header;

    txlMeta_soks_string_keys(TXLAggregatePartisanScore,aggregateId,chamber);

    txlMeta_soks_number_keys(TXLAggregatePartisanScore,partyId,session,score);

    txlMeta_soks_date_keys(TXLAggregatePartisanScore,updatedAt);

    txlMeta_soks_footer;
}

+ (NSValueTransformer *)updatedAtJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightLocalDateFormatter] dateFromString:value];
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightLocalDateFormatter] stringFromDate:value];
    }];
}

@end

txlMeta_keys_impl(TXLAggregatePartisanScore,aggregateId,chamber,partyId,session,score,updatedAt);
