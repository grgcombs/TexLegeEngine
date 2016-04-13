//
//  TXLDataConversion.m
//  TexLege
//
//  Created by Gregory Combs on 4/3/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLDataConversion.h"
#import "TXLModel.h"
@import ReactiveCocoa;
@import Asterism;

RACSequence * TXLFilterListResponseForValidModels(OVCResponse *response, NSString *primaryKey);

RACSequence * TXLFilterListResponseForValidModels(OVCResponse *response, NSString *primaryKey)
{
    if (TXLTypeIsNull(response) || !TXLTypeArrayOrNil(response.result))
        return nil;
    primaryKey = TXLTypeNonEmptyStringOrNil(primaryKey);
    NSCParameterAssert(primaryKey != NULL);
    if (!primaryKey)
        return nil;
    RACSequence *results = [[[response.result rac_sequence] filter:^BOOL(TXLModel *item) {
        if (TXLTypeIsNull(item) ||
            (!TXLValueIfClass(TXLModel,item) &&
             !TXLTypeDictionaryOrNil(item)) ||
            TXLTypeIsNull(item[primaryKey]))
        {
            return NO;
        }
        return YES;
    }] copy];
    return results;
}

NSDictionary * TXLMapListResponseToDictWithKey(OVCResponse *response, NSString *primaryKey)
{
    return [[TXLFilterListResponseForValidModels(response, primaryKey)
             foldLeftWithStart:[@{} mutableCopy]
                        reduce:^id(NSMutableDictionary *collection, TXLModel *item)
             {
                 collection[item[primaryKey]] = item;
                 return collection;
             }] copy];
}

NSDictionary * TXLMapListResponseToGroupedDictWithKey(OVCResponse *response, NSString *groupByKey)
{
    NSArray *results = TXLFilterListResponseForValidModels(response, groupByKey).array;
    if (!TXLTypeNonEmptyArrayOrNil(results))
        return @{};
    return ASTGroupBy(results, groupByKey);
}

NSDictionary * TXLMapListResponseToGroupedDictWithNestedKeys(OVCResponse *response, NSString *groupOneKey, NSString *groupTwoKey)
{
    NSArray *results = TXLFilterListResponseForValidModels(response, groupTwoKey).array;
    if (!TXLTypeNonEmptyArrayOrNil(results))
        return @{};

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    for (TXLModel *model in results)
    {
        id<NSCopying> groupOne = [model valueForKey:groupOneKey];
        if (TXLTypeIsNull(groupOne))
            continue;
        id<NSCopying> groupTwo = [model valueForKey:groupTwoKey];
        if (TXLTypeIsNull(groupTwo))
            continue;

        NSMutableDictionary *groupDictionary = [[NSMutableDictionary alloc] initWithDictionary:(dictionary[groupOne])];

        NSArray *group = groupDictionary[groupTwo] ?: @[];

        groupDictionary[groupTwo] = [group arrayByAddingObject:model];

        dictionary[groupOne] = [groupDictionary copy];
    }
    
    return [dictionary copy];
}

/*
id TXLMapValidDetailsResponse(OVCResponse *response, Class expectedClass)
{
    if (TXLTypeIsNull(response) ||
        TXLTypeIsNull(response.result) ||
        (!TXLValueIfClass(TXLModel,response.result) &&
         !TXLTypeDictionaryOrNil(response.result)))
    {
        return @{};
    }
    return response.result;
}
*/
