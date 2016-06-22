//
//  TXLConstants.h
//  TexLege
//
//  Created by Gregory Combs on 3/30/15
//  Copyright (c) 2014 TexLege. All rights reserved.
//

@import Foundation;
#import "TXLMetaMacros.h"

#define txlConfig_struct_def(...)  metamacro_foreach(txlMeta_struct_item_def,, __VA_ARGS__)

extern const struct TXLCommonConfig {

    txlConfig_struct_def(
                         openstatesStateId,
                         openstatesBaseURL,
                         opencivicdataBaseURL,
                         influenceBaseURL,
                         legislatureBaseURL,
                         databaseName,
                         databaseVersion
                         )

} TXLCommonConfig;

typedef struct {
    txlConfig_struct_def(
                         configType,
                         sunlightApiKey,
                         texlegeBaseURL,
                         texlegeUser,
                         texlegePassword,
                         crashlyticsApiKey
                         )
} TXLPrivateConfigType;

BOOL TXLPrivateConfigIsValid(TXLPrivateConfigType config);
BOOL TXLPrivateConfigsAreEqual(TXLPrivateConfigType config1, TXLPrivateConfigType config2);

/**
 *  @author Greg Combs, Jun 16, 2016
 *
 *  Use the constant struct settings in TXLPrivateConfigDevelopment when running unit tests 
 *  against a localhost REST server on port 4567.
 */
extern const  TXLPrivateConfigType TXLPrivateConfigDevelopment;

/**
 *  @author Greg Combs, Jun 16, 2016
 *
 *  Use the constant struct settings in TXLPrivateConfigProduction when running against
 *  a the production/release REST server on TexLege.
 */
extern const  TXLPrivateConfigType TXLPrivateConfigProduction;

extern NSURL * TXLOpenStatesBaseURL;
extern NSTimeZone *TXLCapitolTimeZone;

