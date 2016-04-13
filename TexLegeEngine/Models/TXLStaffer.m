//
//  TXLStaffer
//  TexLege
//
//  Created by Gregory Combs on 6/19/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLStaffer.h"
#import "TXLDateUtils.h"

#define txlPropToJSON(KEY,PATH) txlMeta_KEY(TXLStaffer,KEY): PATH

@interface TXLStaffer ()

txlMeta_props_copyrw_def(NSString,staffId,legId,email,name,title);

txlMeta_props_copyrw_def(NSDate,updatedAt);

@end

@implementation TXLStaffer

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             txlPropToJSON(staffId,@"staff_id"),
             txlPropToJSON(legId,@"leg_id"),
             txlPropToJSON(email,@"email"),
             txlPropToJSON(name,@"name"),
             txlPropToJSON(title,@"title"),
             txlPropToJSON(updatedAt,@"updated_at"),
             };
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    if (!TXLTypeNonEmptyStringOrNil(key))
        return nil;

    txlMeta_ofks_keys(TXLStaffer,staffId,legId,email,name,title,updatedAt);

    txlMeta_ofks_header;

    txlMeta_ofks_footer;
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    txlMeta_soks_header;

    txlMeta_soks_string_keys(TXLStaffer,staffId,legId,email,name,title);

    txlMeta_soks_date_keys(TXLStaffer,updatedAt);

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

txlMeta_keys_impl(TXLStaffer,staffId,legId,email,name,title,updatedAt);
