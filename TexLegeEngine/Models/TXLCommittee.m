//
//  TXLCommittee.m
//  TexLege
//
//  Created by Gregory Combs on 6/19/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLCommittee.h"
#import "TXLDateUtils.h"

#define txlPropToJSON(KEY,PATH) txlMeta_KEY(TXLCommittee,KEY): PATH

@interface TXLCommittee ()


txlMeta_props_copyrw_def(NSString,chamber,committeeId,name,parentId,subCommittee,clerk,clerkEmail,location,phone,txlonlineId);
txlMeta_props_copyrw_def(NSArray,members,oldIds);
txlMeta_props_copyrw_def(NSDate,updatedAt,createdAt);
txlMeta_props_copyrw_def(NSURL,url);

@end

@implementation TXLCommittee

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             txlPropToJSON(chamber,@"chamber"),
             txlPropToJSON(name,@"committee"),
             txlPropToJSON(committeeId,@"id"),
             txlPropToJSON(members,@"members"),
             txlPropToJSON(oldIds,@"all_ids"),
             txlPropToJSON(parentId,@"parent_id"),
             txlPropToJSON(subCommittee,@"subcommittee"),
             txlPropToJSON(createdAt,@"created_at"),
             txlPropToJSON(updatedAt,@"updated_at"),
             txlPropToJSON(clerk,@"clerk"),
             txlPropToJSON(clerkEmail,@"clerk_email"),
             txlPropToJSON(location,@"location"),
             txlPropToJSON(phone,@"phone"),
             txlPropToJSON(txlonlineId,@"txlonline_id"),
             txlPropToJSON(url,@"url"),
             };
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    if (!TXLTypeNonEmptyStringOrNil(key))
        return nil;

    txlMeta_ofks_keys(TXLCommittee,chamber,committeeId,name,parentId,subCommittee,members,oldIds,updatedAt,createdAt,clerk,clerkEmail,location,phone,txlonlineId,url);

    txlMeta_ofks_header;

    txlMeta_ofks_footer;
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    txlMeta_soks_header;

    txlMeta_soks_string_keys(TXLCommittee,chamber,committeeId,name,parentId,subCommittee,clerk,clerkEmail,location,phone,txlonlineId);
    txlMeta_soks_array_keys(TXLCommittee,members,oldIds);
    txlMeta_soks_date_keys(TXLCommittee,updatedAt,createdAt);
    txlMeta_soks_url_keys(TXLCommittee,url);

    txlMeta_soks_footer;
}

- (NSString *)shortDescription
{
    return [NSString stringWithFormat:@"%@: %@ (%@)", self.committeeId, self.name, self.chamber];
}

#pragma mark - Transformers

+ (NSValueTransformer *)urlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] dateFromString:value];
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] stringFromDate:value];
    }];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] dateFromString:value];
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] stringFromDate:value];
    }];
}

@end

txlMeta_keys_impl(TXLCommittee,chamber,committeeId,name,parentId,subCommittee,oldIds,members,updatedAt,createdAt,clerk,clerkEmail,location,phone,txlonlineId,url);

