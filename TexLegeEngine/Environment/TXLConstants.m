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

#ifdef TARGETING_STAGING

const struct TXLPrivateConfig TXLPrivateConfig = {
    .configType = @"development",
    .sunlightApiKey = @"350284d0c6af453b9b56f6c1c7fea1f9",
    .texlegeBaseURL = @"http://localhost:4567/texlege/v1/",
    .texlegeUser = @"texlegeRead",
    .texlegePassword = @"uiNrWFJmdMto6H6a7",
    .crashlyticsApiKey = @"7f920088e925e57cb9f436fa327d06fefc4930dd",
    
};

#else

const struct TXLPrivateConfig TXLPrivateConfig = {
    .configType = @"release",
    .sunlightApiKey = @"350284d0c6af453b9b56f6c1c7fea1f9",
    .texlegeBaseURL = @"http://data.texlege.com/texlege/v1/",
    .texlegeUser = @"texlegeRead",
    .texlegePassword = @"uiNrWFJmdMto6H6a7",
    .crashlyticsApiKey = @"7f920088e925e57cb9f436fa327d06fefc4930dd",
};

#endif


NSURL * TXLOpenStatesBaseURL;
NSTimeZone * TXLCapitolTimeZone;

void __attribute__((constructor)) TXLConstantsInitializer() {
    TXLOpenStatesBaseURL = [NSURL URLWithString:TXLCommonConfig.openstatesBaseURL];
//    TXLOpenStatesBaseURL = [NSURL URLWithString:IF_STAGING(@"http://myapp.com/api/staging",
//                                                           @"http://myapp.com/api")];

    TXLCapitolTimeZone = [NSTimeZone timeZoneWithName:@"America/Chicago"];
    NSCParameterAssert(TXLCapitolTimeZone != NULL);
}

