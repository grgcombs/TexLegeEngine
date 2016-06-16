//
//  TXLDataLoader.h
//  TexLege
//
//  Created by Gregory Combs on 12/27/15.
//  Copyright © 2015 TexLege. All rights reserved.
//

@import Foundation;
#import "TXLMetaMacros.h"
#import "TXLDatabaseManager.h"

@class RACSignal;

@protocol TXLDatabaseObserver <NSObject>

- (void)databaseModified:(NSNotification *)notification;

@end

@protocol TXLDatabaseNotifer <NSObject>

- (void)addDataModificationObserver:(id<TXLDatabaseObserver>)observer;
- (void)removeDataModificationObserver:(id<TXLDatabaseObserver>)observer;

@end


@interface TXLDataLoader : NSObject<TXLDatabaseNotifer>

- (instancetype)initWithClientConfig:(TXLPrivateConfigType)clientConfig;

@property (nonatomic,strong,readonly) YapDatabaseConnection *uiConnection;
@property (nonatomic,strong,readonly) YapDatabaseConnection *bgConnection;

- (RACSignal *)loadLegislators;

@end


#define txlDataLoader_struct_def(...)  metamacro_foreach(txlMeta_struct_item_def,, __VA_ARGS__)

extern const struct TXLDataLoaderKeys {

    // view keys

    txlDataLoader_struct_def(
                             legislatorListView,
                             legislatorListSearch
                             )

} TXLDataLoaderKeys;

