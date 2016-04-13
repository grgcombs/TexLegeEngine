//
//  TXLPartisanScore.h
//  TexLege
//
//  Created by Gregory Combs on 6/19/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLModel.h"

@interface TXLPartisanScore : TXLModel

txlMeta_props_copyro_def(NSString,scoreId,legId);

txlMeta_props_copyro_def(NSNumber,scoreAvg,score,stdErr,session);

txlMeta_props_copyro_def(NSDate,updatedAt);

+ (BOOL)supportsSecureCoding;

@end

txlMeta_keys_def(TXLPartisanScore,scoreId,legId,scoreAvg,score,stdErr,session,updatedAt);
