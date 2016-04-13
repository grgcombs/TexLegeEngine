//
//  TXLAggregatePartisanScore.h
//  TexLege
//
//  Created by Gregory Combs on 6/19/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLModel.h"

@interface TXLAggregatePartisanScore : TXLModel

txlMeta_props_copyro_def(NSString,aggregateId,chamber);

txlMeta_props_copyro_def(NSNumber,partyId,session,score);

txlMeta_props_copyro_def(NSDate,updatedAt);

+ (BOOL)supportsSecureCoding;

@end

txlMeta_keys_def(TXLAggregatePartisanScore,aggregateId,chamber,partyId,session,score,updatedAt);
