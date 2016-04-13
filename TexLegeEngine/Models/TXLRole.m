//
//  TXLRole.m
//  TexLege
//
//  Created by Gregory Combs on 4/4/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLRole.h"
#import "TXLDateUtils.h"

#define txlPropToJSON(KEY,PATH) txlMeta_KEY(TXLRole,KEY): PATH

@interface TXLRole ()

txlMeta_props_copyrw_def(NSString,chamber,committee,committeeId,district,party,position,term,type);
txlMeta_props_copyrw_def(NSDate,endDate,startDate);

@end

@implementation TXLRole

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             txlPropToJSON(chamber,@"chamber"),
             txlPropToJSON(committee,@"committee"),
             txlPropToJSON(committeeId,@"committee_id"),
             txlPropToJSON(district,@"district"),
             txlPropToJSON(party,@"party"),
             txlPropToJSON(position,@"position"),
             txlPropToJSON(term,@"term"),
             txlPropToJSON(type ,@"type"),
             txlPropToJSON(endDate,@"endDate"),
             txlPropToJSON(startDate,@"startDate"),
             };
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    if (!TXLTypeNonEmptyStringOrNil(key))
        return nil;

    txlMeta_ofks_keys(TXLRole,chamber,committee,committeeId,district,party,position,term,type);
    txlMeta_ofks_keys(TXLRole,endDate,startDate);

    txlMeta_ofks_header;

    txlMeta_ofks_footer;
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    txlMeta_soks_header;

    txlMeta_soks_string_keys(TXLRole,chamber,committee,committeeId,district,party,position,term,type);
    txlMeta_soks_date_keys(TXLRole,endDate,startDate);

    txlMeta_soks_footer;
}

#pragma mark - Transformers

+ (NSValueTransformer *)endDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] dateFromString:value];
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] stringFromDate:value];
    }];
}

+ (NSValueTransformer *)startDateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] dateFromString:value];
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] stringFromDate:value];
    }];
}

@end

txlMeta_keys_impl(TXLRole,chamber,committee,committeeId,district,endDate,party,position,startDate,term,type);

