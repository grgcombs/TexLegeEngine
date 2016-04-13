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

extern const struct TXLPrivateConfig {

    txlConfig_struct_def(
                         configType,
                         sunlightApiKey,
                         texlegeBaseURL,
                         texlegeUser,
                         texlegePassword,
                         crashlyticsApiKey
                         )

} TXLPrivateConfig;

extern NSURL * TXLOpenStatesBaseURL;
extern NSTimeZone *TXLCapitolTimeZone;

