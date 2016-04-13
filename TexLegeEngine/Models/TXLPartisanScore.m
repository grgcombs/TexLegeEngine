//
//  TXLPartisanScore.m
//  TexLege
//
//  Created by Gregory Combs on 6/19/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLPartisanScore.h"
#import "TXLDateUtils.h"

#define txlPropToJSON(KEY,PATH) txlMeta_KEY(TXLPartisanScore,KEY): PATH

@interface TXLPartisanScore ()

txlMeta_props_copyrw_def(NSString,scoreId,legId);

txlMeta_props_copyrw_def(NSNumber,scoreAvg,score,stdErr,session);

txlMeta_props_copyrw_def(NSDate,updatedAt);

@end

@implementation TXLPartisanScore

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             txlPropToJSON(scoreId,@"score_id"),
             txlPropToJSON(legId,@"leg_id"),
             txlPropToJSON(scoreAvg,@"score_avg"),
             txlPropToJSON(stdErr,@"std_error"),
             txlPropToJSON(session,@"session"),
             txlPropToJSON(updatedAt,@"updated_at"),
             };
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    if (!TXLTypeNonEmptyStringOrNil(key))
        return nil;

    txlMeta_ofks_keys(TXLPartisanScore,scoreId,legId,scoreAvg,score,stdErr,session,updatedAt);

    txlMeta_ofks_header;

    txlMeta_ofks_footer;
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    txlMeta_soks_header;

    txlMeta_soks_string_keys(TXLPartisanScore,scoreId,legId);

    txlMeta_soks_number_keys(TXLPartisanScore,scoreAvg,score,stdErr,session);

    txlMeta_soks_date_keys(TXLPartisanScore,updatedAt);

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

txlMeta_keys_impl(TXLPartisanScore,scoreId,legId,scoreAvg,score,stdErr,session,updatedAt);
