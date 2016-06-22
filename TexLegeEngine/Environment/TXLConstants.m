//
//  TXLConstants.m
//  TexLege
//
//  Created by Gregory Combs on 3/26/15
//  Copyright (c) 2014 TexLege. All rights reserved.
//

#import "TexLege-Environment.h"
#import "TXLConstants.h"

// Use this file to define the values of the variables declared in the header.
// For data types that aren't compile-time constants (e.g. NSURL), use the
// TXLConstantsInitializer function below.

// See TexLege-Environment.h for macros that are likely applicable in
// this file. TARGETING_{STAGING,PRODUCTION} and IF_STAGING are probably
// the most useful.

const struct TXLCommonConfig TXLCommonConfig = {
    .openstatesStateId = @"tx",
    .openstatesBaseURL = @"http://openstates.org/api/v1/",
    .opencivicdataBaseURL = @"https://api.opencivicdata.org/",
    .influenceBaseURL = @"http://transparencydata.com/api/1.0/",
    .legislatureBaseURL = @"http://www.legis.state.tx.us/",
    .databaseName = @"TexLege",
    .databaseVersion = @"3",
};

const TXLPrivateConfigType TXLPrivateConfigDevelopment = {
    .configType = @"development",
    .sunlightApiKey = @"350284d0c6af453b9b56f6c1c7fea1f9",
    .texlegeBaseURL = @"http://localhost:4567/texlege/v1/",
    .texlegeUser = @"texlegeRead",
    .texlegePassword = @"uiNrWFJmdMto6H6a7",
    .crashlyticsApiKey = @"7f920088e925e57cb9f436fa327d06fefc4930dd",
    
};

const TXLPrivateConfigType TXLPrivateConfigProduction = {
    .configType = @"release",
    .sunlightApiKey = @"350284d0c6af453b9b56f6c1c7fea1f9",
    .texlegeBaseURL = @"http://data.texlege.com:8395/texlege/v1/",
    .texlegeUser = @"texlegeRead",
    .texlegePassword = @"9ru7wQG)efsKxts",
    .crashlyticsApiKey = @"7f920088e925e57cb9f436fa327d06fefc4930dd",
};



NSURL * TXLOpenStatesBaseURL;
NSTimeZone * TXLCapitolTimeZone;

void __attribute__((constructor)) TXLConstantsInitializer() {

    TXLOpenStatesBaseURL = [NSURL URLWithString:TXLCommonConfig.openstatesBaseURL];
//    TXLOpenStatesBaseURL = [NSURL URLWithString:IF_STAGING(@"http://myapp.com/api/staging",
//                                                           @"http://myapp.com/api")];

    TXLCapitolTimeZone = [NSTimeZone timeZoneWithName:@"America/Chicago"];
    NSCParameterAssert(TXLCapitolTimeZone != NULL);
}

BOOL TXLPrivateConfigIsValid(TXLPrivateConfigType config)
{
    return (TXLTypeNonEmptyStringOrNil(config.configType)
            && TXLTypeNonEmptyStringOrNil(config.sunlightApiKey)
            && TXLTypeNonEmptyStringOrNil(config.texlegeBaseURL)
            && TXLTypeNonEmptyStringOrNil(config.texlegeUser)
            && TXLTypeNonEmptyStringOrNil(config.texlegePassword)
            // Crashlytics is optional
            && (TXLTypeIsNull(config.crashlyticsApiKey)
                || TXLTypeNonEmptyStringOrNil(config.crashlyticsApiKey)));
}

BOOL TXLPrivateConfigsAreEqual(TXLPrivateConfigType config1, TXLPrivateConfigType config2)
{
    BOOL isConfig1Valid = TXLPrivateConfigIsValid(config1);
    BOOL isConfig2Valid = TXLPrivateConfigIsValid(config2);

    if (isConfig1Valid != isConfig2Valid)
        return NO;

    if (isConfig1Valid == NO && isConfig2Valid == NO)
        return YES; // why would this happen and would this ever be a good idea?

    if (![config1.configType isEqualToString:config2.configType])
        return NO;
    if (![config1.sunlightApiKey isEqualToString:config2.sunlightApiKey])
        return NO;
    if (![config1.texlegeBaseURL isEqualToString:config2.texlegeBaseURL])
        return NO;
    if (![config1.texlegeUser isEqualToString:config2.texlegeUser])
        return NO;
    if (![config1.texlegePassword isEqualToString:config2.texlegePassword])
        return NO;

    // Crashlytics is optional
    
    BOOL crashlyticsIsEqualOrEmpty = NO;

    NSString *crashlytics1 = TXLTypeNonEmptyStringOrNil(config1.crashlyticsApiKey);
    NSString *crashlytics2 = TXLTypeNonEmptyStringOrNil(config2.crashlyticsApiKey);

    if (!crashlytics1 && !crashlytics2)
        crashlyticsIsEqualOrEmpty = YES;
    else if (crashlytics1 && crashlytics2)
        crashlyticsIsEqualOrEmpty = [crashlytics1 isEqualToString:crashlytics2];
    else // One of these must be a string and the other is not
        crashlyticsIsEqualOrEmpty = NO;

    return crashlyticsIsEqualOrEmpty;
}

