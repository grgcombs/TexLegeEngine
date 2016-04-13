//
//  TXLDataModelCombinator.m
//  TexLege
//
//  Created by Gregory Combs on 4/8/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLDataModelCombinator.h"
#import "TXLLegislator.h"
#import "TXLCommittee.h"
#import <CocoaLumberjack/DDLogMacros.h>
#import "TexLege-Environment.h"

@interface TXLDataModelCombinator ()

@end

@implementation TXLDataModelCombinator

+ (RACSignal *)mergeModelsFromSignals:(RACSignal *)signalOne and:(RACSignal *)signalTwo excludingKeys:(NSArray *)excludingKeys
{
    if (!signalOne)
        return signalTwo;
    if (!signalTwo)
        return signalOne;
    return [RACSignal combineLatest:@[signalOne,signalTwo]
                             reduce:^(NSDictionary *oneDict, NSDictionary *twoDict)
            {
                NSMutableArray *unmatched = [@[] mutableCopy];
                NSMutableDictionary *composite = [[NSMutableDictionary alloc] initWithDictionary:oneDict];
                [oneDict enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, TXLModel *oneModel, BOOL *stop) {
                    TXLModel *twoModel = twoDict[identifier];
                    if (!twoModel)
                    {
                        // fallback in case we have an outdated ID
                        if ([oneModel conformsToProtocol:@protocol(TXLOldModelIdentifiers)]) {
                            for (NSString *oldId in [(TXLModel<TXLOldModelIdentifiers> *)oneModel oldIds])
                            {
                                twoModel = twoDict[oldId];
                                if (twoModel)
                                    break;
                            }
                        }
                        if (!twoModel)
                        {
                            [unmatched addObject:oneModel];
                            return;
                        }
                    }
                    TXLModel *merged = composite[identifier];
                    [merged mergeValuesForKeysFromModel:twoModel excludingKeys:excludingKeys];
                    composite[identifier] = merged;
                }];

                if (unmatched.count &&
                    (LOG_LEVEL_DEF & DDLogFlagWarning))
                {
                    NSMutableString *unmatchedMessage = [@"\n" mutableCopy];
                    for (TXLModel *model in unmatched)
                    {
                        [unmatchedMessage appendFormat:@"    - %@\n", [model shortDescription]];
                    }
                    DDLogWarn(@"Unable to find matches for the following model: %@", unmatchedMessage);
                }

                return [composite copy];
            }];
}

@end
