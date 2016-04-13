//
//  TXLOffice.m
//  TexLege
//
//  Created by Gregory Combs on 4/4/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLOffice.h"

#define txlPropToJSON(KEY,PATH) txlMeta_KEY(TXLOffice,KEY): PATH

@interface TXLOffice ()

txlMeta_props_copyrw_def(NSString,address,email,fax,name,phone,type);

@end

@implementation TXLOffice

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             txlPropToJSON(address,@"address"),
             txlPropToJSON(email,@"email"),
             txlPropToJSON(fax,@"fax"),
             txlPropToJSON(name,@"name"),
             txlPropToJSON(phone,@"phone"),
             txlPropToJSON(type,@"type"),
             };
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    if (!TXLTypeNonEmptyStringOrNil(key))
        return nil;

    txlMeta_ofks_keys(TXLOffice,address,email,fax,name,phone,type);

    txlMeta_ofks_header;

    txlMeta_ofks_footer;
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    txlMeta_soks_header;

    txlMeta_soks_string_keys(TXLOffice,address,email,fax,name,phone,type);

    txlMeta_soks_footer;
}

@end

txlMeta_keys_impl(TXLOffice,address,email,fax,name,phone,type);
