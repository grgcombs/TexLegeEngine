//
//  TXLOffice.h
//  TexLege
//
//  Created by Gregory Combs on 4/4/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLModel.h"

@interface TXLOffice : TXLModel

txlMeta_props_copyro_def(NSString,address,email,fax,name,phone,type);

+ (BOOL)supportsSecureCoding;

@end

txlMeta_keys_def(TXLOffice,address,email,fax,name,phone,type);
