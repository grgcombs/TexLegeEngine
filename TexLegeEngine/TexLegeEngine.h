//
//  TexLegeEngine.h
//  TexLegeEngine
//
//  Created by Gregory Combs on 3/26/16.
//  Copyright © 2016 TexLege. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for TexLegeEngine.
FOUNDATION_EXPORT double TexLegeEngineVersionNumber;

//! Project version string for TexLegeEngine.
FOUNDATION_EXPORT const unsigned char TexLegeEngineVersionString[];

#import <TexLegeEngine/TXLTypeCheck.h>
#import <TexLegeEngine/TXLConstants.h>
#import <TexLegeEngine/TXLLogFileManager.h>
#import <TexLegeEngine/TXLMetaMacros.h>
#import <TexLegeEngine/TXLDataConversion.h>
#import <TexLegeEngine/TXLDateUtils.h>
#import <TexLegeEngine/TXLReachability.h>
#import <TexLegeEngine/TXLMetadata.h>
#import <TexLegeEngine/TXLModel.h>
#import <TexLegeEngine/TXLOffice.h>
#import <TexLegeEngine/TXLPartisanScore.h>
#import <TexLegeEngine/TXLRole.h>
#import <TexLegeEngine/TXLStaffer.h>
#import <TexLegeEngine/TXLAggregatePartisanScore.h>
#import <TexLegeEngine/TXLCommittee.h>
#import <TexLegeEngine/TXLLegislator.h>
#import <TexLegeEngine/TXLDatabaseManager.h>
#import <TexLegeEngine/TXLDataLoader.h>
#import <TexLegeEngine/TXLDataModelCombinator.h>
#import <TexLegeEngine/TXLOpenStatesClient.h>
#import <TexLegeEngine/TXLTexLegeClient.h>
#import <TexLegeEngine/TXLBlockListDataSource.h>
#import <TexLegeEngine/TXLLegislatorListViewController.h>
#import <TexLegeEngine/TXLModelListViewController.h>
#import <TexLegeEngine/TXLBlockTableViewController.h>

@interface TexLegeEngine : NSObject
+ (instancetype)instanceWithPrivateConfig:(TXLPrivateConfigType)privateConfig;
+ (instancetype)instance;
@property (atomic,readonly) TXLPrivateConfigType privateConfig;
@property (nonatomic,strong,readonly) TXLDataLoader *dataLoader;
@end
