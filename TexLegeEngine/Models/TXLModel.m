//
//  TXLModel.m
//  TexLege
//
//  Created by Gregory Combs on 4/6/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLModel.h"

@implementation TXLModel

- (id)objectForKeyedSubscript:(NSString *)key
{
    if (!TXLTypeNonEmptyStringOrNil(key))
        return nil;

    if (![self.class.propertyKeys containsObject:key])
        return nil;

    return [self valueForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    txlMeta_soks_header

    if (![self.class.propertyKeys containsObject:key])
        return;

    [self setValue:object forKey:key];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{};
}

- (void)mergeValuesForKeysFromModel:(MTLModel *)model excludingKeys:(NSArray *)excludedKeys
{
    if (!model || ![model isMemberOfClass:self.class])
    {
        [super mergeValuesForKeysFromModel:model];
        return;
    }
    TXLModel *other = (TXLModel *)model;

    NSSet *propertyKeys = self.class.propertyKeys;

    for (NSString *key in propertyKeys)
    {
        if (excludedKeys && [excludedKeys containsObject:key])
            continue;
        id theirs = other[key];

        if (TXLTypeIsNull(theirs))
            continue;
        self[key] = theirs;
    }
}

- (NSString *)shortDescription
{
    return [self description];
}

@end
