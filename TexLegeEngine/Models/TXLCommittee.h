//
//  TXLCommittee.h
//  TexLege
//
//  Created by Gregory Combs on 6/19/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLModel.h"

@interface TXLCommittee : TXLModel<TXLOldModelIdentifiers>

txlMeta_props_copyro_def(NSString,chamber,committeeId,name,parentId,subCommittee,clerk,clerkEmail,location,phone,txlonlineId);

txlMeta_props_copyro_def(NSArray,members,oldIds);

txlMeta_props_copyro_def(NSDate,updatedAt,createdAt);

txlMeta_props_copyro_def(NSURL,url);

+ (BOOL)supportsSecureCoding;

@end

txlMeta_keys_def(TXLCommittee,chamber,committeeId,name,parentId,subCommittee,oldIds,members,updatedAt,createdAt,clerk,clerkEmail,location,phone,txlonlineId,url);
