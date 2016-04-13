//
//  TXLMetadata.h
//  TexLege
//
//  Created by Gregory Combs on 4/8/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLModel.h"

typedef NS_ENUM(uint8_t, TXLMetadataChamber) {
    TXLMetadataChamberUnknown,
    TXLMetadataChamberLower,
    TXLMetadataChamberUpper,
    TXLMetadataChamberJoint,
};

@interface TXLMetadata : TXLModel

txlMeta_props_copyro_def(NSString,abbreviation,capitolTimezone,stateId,legislatureName,stateName);

txlMeta_props_copyro_def(NSURL,legislatureUrl);

txlMeta_props_copyro_def(NSDate,updatedAt);

txlMeta_props_copyro_def(NSDictionary,chambers,sessionDetails)

txlMeta_props_copyro_def(NSArray,capitolMaps,featureFlags,terms);

+ (BOOL)supportsSecureCoding;

@end

txlMeta_keys_def(TXLMetadata,abbreviation,capitolTimezone,stateId,legislatureName,stateName,legislatureUrl,updatedAt,capitolMaps,chambers,featureFlags,sessionDetails,terms);

txlMeta_keys_def(TXLMetadataChamber,unknown,lower,upper,joint);

