//
//  TXLStaffer.h
//  TexLege
//
//  Created by Gregory Combs on 6/19/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLModel.h"

@interface TXLStaffer : TXLModel

txlMeta_props_copyro_def(NSString,staffId,legId,email,name,title);

txlMeta_props_copyro_def(NSDate,updatedAt);

+ (BOOL)supportsSecureCoding;

@end

txlMeta_keys_def(TXLStaffer,staffId,legId,email,name,title,updatedAt);
