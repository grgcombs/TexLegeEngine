//
//  TXLMetadata.m
//  TexLege
//
//  Created by Gregory Combs on 4/8/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLMetadata.h"
#import "TXLDateUtils.h"

#define txlPropToJSON(KEY,PATH) txlMeta_KEY(TXLMetadata,KEY): PATH

@interface TXLMetadata ()

txlMeta_props_copyrw_def(NSString,abbreviation,capitolTimezone,stateId,legislatureName,stateName);
txlMeta_props_copyrw_def(NSURL,legislatureUrl);
txlMeta_props_copyrw_def(NSDate,updatedAt);
txlMeta_props_copyrw_def(NSDictionary,chambers,sessionDetails)
txlMeta_props_copyrw_def(NSArray,capitolMaps,featureFlags,terms);

@end

@implementation TXLMetadata

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             txlPropToJSON(abbreviation,@"abbreviation"),
             txlPropToJSON(capitolTimezone,@"capitol_timezone"),
             txlPropToJSON(stateId,@"id"),
             txlPropToJSON(legislatureName,@"legislature_name"),
             txlPropToJSON(stateName,@"name"),
             txlPropToJSON(legislatureUrl,@"legislature_url"),
             txlPropToJSON(updatedAt,@"latest_update"),
             txlPropToJSON(capitolMaps,@"capitol_maps"),
             txlPropToJSON(chambers,@"chambers"),
             txlPropToJSON(featureFlags,@"feature_flags"),
             txlPropToJSON(sessionDetails,@"session_details"),
             txlPropToJSON(terms,@"terms"),
             };
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    if (!TXLTypeNonEmptyStringOrNil(key))
        return nil;

    txlMeta_ofks_keys(TXLMetadata,abbreviation,capitolTimezone,stateId,legislatureName,stateName);
    txlMeta_ofks_keys(TXLMetadata,legislatureUrl);
    txlMeta_ofks_keys(TXLMetadata,updatedAt);
    txlMeta_ofks_keys(TXLMetadata,chambers,sessionDetails);
    txlMeta_ofks_keys(TXLMetadata,capitolMaps,featureFlags,terms);

    txlMeta_ofks_header;

    txlMeta_ofks_footer;
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    txlMeta_soks_header;

    txlMeta_soks_string_keys(TXLMetadata,abbreviation,capitolTimezone,stateId,legislatureName,stateName);
    txlMeta_soks_url_keys(TXLMetadata,legislatureUrl);
    txlMeta_soks_date_keys(TXLMetadata,updatedAt);
    txlMeta_soks_dictionary_keys(TXLMetadata,chambers,sessionDetails);
    txlMeta_soks_array_keys(TXLMetadata,capitolMaps,featureFlags,terms);

    txlMeta_soks_footer;
}

#pragma mark - Transformers

+ (NSValueTransformer *)updatedAtJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] dateFromString:value];
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] stringFromDate:value];
    }];
}

+ (NSValueTransformer *)legislatureUrlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end

txlMeta_keys_impl(TXLMetadata,abbreviation,capitolTimezone,stateId,legislatureName,stateName,legislatureUrl,updatedAt,capitolMaps,chambers,featureFlags,sessionDetails,terms);

txlMeta_keys_impl(TXLMetadataChamber,unknown,lower,upper,joint);
