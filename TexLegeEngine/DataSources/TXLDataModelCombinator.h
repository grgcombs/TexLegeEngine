//
//  TXLDataModelCombinator.h
//  TexLege
//
//  Created by Gregory Combs on 4/8/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import ReactiveCocoa;

@interface TXLDataModelCombinator : NSObject

+ (RACSignal *)mergeModelsFromSignals:(RACSignal *)signalOne and:(RACSignal *)signalTwo excludingKeys:(NSArray *)excludingKeys;

@end
