//
//  TXLRole.h
//  TexLege
//
//  Created by Gregory Combs on 4/4/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLModel.h"

@interface TXLRole : TXLModel

txlMeta_props_copyro_def(NSString,chamber,committee,committeeId,district,party,position,term,type);

txlMeta_props_copyro_def(NSDate,endDate,startDate);

+ (BOOL)supportsSecureCoding;

@end

txlMeta_keys_def(TXLRole,chamber,committee,committeeId,district,endDate,party,position,startDate,term,type);
