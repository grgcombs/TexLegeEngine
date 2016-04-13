//
//  TXLDataLoader.m
//  TexLege
//
//  Created by Gregory Combs on 12/27/15.
//  Copyright © 2015 TexLege. All rights reserved.
//

#import "TXLDataLoader.h"
#import "TXLOpenStatesClient.h"
#import "TXLTexLegeClient.h"
#import "TXLDataModelCombinator.h"
#import "TXLLegislator.h"
#import "TXLCommittee.h"
#import "TXLYapDatabase.h"

static TXLDataLoader *sharedLoader = nil;

@interface TXLDataLoader()

@property (nonatomic,strong) TXLDatabaseManager *dbManager;
@property (nonatomic,strong) TXLOpenStatesClient *osClient;
@property (nonatomic,strong) TXLTexLegeClient *txClient;
@property (nonatomic,strong) YapDatabaseConnection *uiConnection;
@property (nonatomic,strong) YapDatabaseConnection *bgConnection;
@property (nonatomic,strong) RACSignal *legislatorListViewSignal;
@property (nonatomic,strong) RACSignal *legislatorListSearchSignal;

@end

@implementation TXLDataLoader

+ (instancetype)currentLoader
{
    if (!sharedLoader)
        sharedLoader = [[TXLDataLoader alloc] init];
    return sharedLoader;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString *path = [TXLDatabaseManager defaultDatabasePathWithName:TXLCommonConfig.databaseName version:TXLCommonConfig.databaseVersion];
        _dbManager = [[TXLDatabaseManager alloc] initWithPath:path];

        _uiConnection = [_dbManager newDatabaseConnection];
        _uiConnection.objectCacheLimit = 500;
        _uiConnection.metadataCacheEnabled = YES;
        _uiConnection.permittedTransactions = YDB_SyncReadTransaction | YDB_MainThreadOnly;

        _bgConnection = [_dbManager newDatabaseConnection];
        _bgConnection.objectCacheEnabled = NO; // no need to cache for write-only
        _bgConnection.metadataCacheEnabled = NO;
        _bgConnection.permittedTransactions = YDB_AnyAsyncTransaction;

        [self registerExtensions];

    }
    return self;
}

- (void)dealloc
{
    [self unregisterExtensions];
}

- (RACSignal *)loadLegislators
{
    if (!_txClient)
        _txClient = [[TXLTexLegeClient alloc] init];
    if (!_osClient)
        _osClient = [[TXLOpenStatesClient alloc] init];

    @weakify(self);

    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);

        [[self.legislatorListViewSignal
          merge:self.legislatorListSearchSignal] subscribeCompleted:^{
            @strongify(self);
            RACSignal *compositeLegislators = [TXLDataModelCombinator mergeModelsFromSignals:[self.osClient fetchLegislators]
                                                                                         and:[self.txClient fetchLegislators]
                                                                               excludingKeys:@[@"legId"]];

            [compositeLegislators subscribeNext:^(NSDictionary *legislators) {
                @strongify(self);
                if (!self)
                    return;

                if (!TXLTypeDictionaryOrNil(legislators).count)
                {
                    NSString *errorMessage = NSLocalizedString(@"Empty or missing legislators data", @"Error Message");
                    DDLogError(@"%@", errorMessage);
                    NSError *error = [NSError errorWithDomain:@"db.data.legislator.list" code:-100 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
                    [subscriber sendError:error];
                    return;
                }

                if (legislators.count != 182)
                {
                    DDLogWarn(@"Data issue concerning number of legislators - expected 182, but received %d", (int)legislators.count);
                }

                [self.bgConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                    [legislators enumerateKeysAndObjectsUsingBlock:^(id legId, TXLLegislator *legislator, BOOL * stop) {
                        [transaction setObject:legislator forKey:legId inCollection:txlMeta_KEY(TXLDataLoader, legislatorListView)];
                    }];
                }];

                [subscriber sendNext:legislators];

            } error:^(NSError *error) {
                [subscriber sendError:error];
            } completed:^{
                [subscriber sendCompleted];
            }];
        }];

        RACDisposable *onDeallocateSignal = [RACDisposable disposableWithBlock:^{}];

        return onDeallocateSignal;
        
    }] setNameWithFormat:@"%@ -loadLegislators", self.class];
}

- (void)registerExtensions
{
    _legislatorListViewSignal = [self registerLegislatorListView];
    _legislatorListSearchSignal = [self registerLegislatorListSearch];
}

- (void)unregisterExtensions
{
    [[self.dbManager unregisterExtensionWithName:txlMeta_KEY(TXLDataLoader, legislatorListView) connection:self.bgConnection]
     subscribeNext:nil];
    [[self.dbManager unregisterExtensionWithName:txlMeta_KEY(TXLDataLoader, legislatorListSearch) connection:self.bgConnection]
     subscribeNext:nil];
}

- (RACSignal *)registerLegislatorListView
{
    int groupingBlockVersion = 1;
    YapDatabaseViewGrouping *grouping = [YapDatabaseViewGrouping withObjectBlock:^NSString *(YapDatabaseReadTransaction *transaction, NSString *collection, NSString *key, TXLLegislator *object) {
        NSString *groupKey = nil;
        if (!TXLValueIfClass(TXLLegislator, object))
            return groupKey;

        groupKey = @(object.localizedCollationSection).stringValue;

        return groupKey;
    }];

    int sortingBlockVersion = 1;
    YapDatabaseViewSorting *sorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(YapDatabaseReadTransaction *transaction, NSString *group, NSString *collection1, NSString *key1, TXLLegislator *object1, NSString *collection2, NSString *key2, TXLLegislator *object2) {
        if (!TXLValueIfClass(TXLLegislator, object1) || !TXLValueIfClass(TXLLegislator, object2))
            return NSOrderedSame;
        return [object1 compare:object2];
    }];

    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSString *versionTag = [NSString stringWithFormat:@"%d-%d-%@", groupingBlockVersion, sortingBlockVersion, locale];

    YapDatabaseView *extension = [[YapDatabaseView alloc] initWithGrouping:grouping sorting:sorting versionTag:versionTag options:nil];

    return [self.dbManager registerExtension:extension withName:txlMeta_KEY(TXLDataLoader, legislatorListView) connection:self.bgConnection];
}

- (RACSignal *)registerLegislatorListSearch
{
    int searchingBlockVersion = 1;
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSString *versionTag = [NSString stringWithFormat:@"%d-%@", searchingBlockVersion, locale];

    NSArray *propertyKeys = @[NSStringFromSelector(@selector(capOffice)),
                              NSStringFromSelector(@selector(district)),
                              NSStringFromSelector(@selector(email)),
                              NSStringFromSelector(@selector(fullName)),
                              NSStringFromSelector(@selector(preferredName))];
    NSArray *searchTokenKeys = ASTMap(propertyKeys, ^NSString*(NSString *propertyKey) {
        return [@"search." stringByAppendingString:propertyKey];
    });

    YapDatabaseFullTextSearchHandler *handler = [YapDatabaseFullTextSearchHandler withObjectBlock:^(NSMutableDictionary *dict, NSString *collection, NSString *key, TXLLegislator *result) {
        [propertyKeys enumerateObjectsUsingBlock:^(NSString *propertyKey, NSUInteger idx, BOOL *stop) {
            NSString *value = TXLTypeNonEmptyStringOrNil(result[propertyKey]);
            if (!value)
                return;
            NSCParameterAssert(searchTokenKeys.count > idx);
            NSString *searchTokenKey = searchTokenKeys[idx];
            NSCParameterAssert(searchTokenKey != NULL);
            dict[searchTokenKey] = value;

        }];
    }];

    YapDatabaseFullTextSearch *extension = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:searchTokenKeys handler:handler versionTag:versionTag];
    return [self.dbManager registerExtension:extension withName:txlMeta_KEY(TXLDataLoader, legislatorListSearch) connection:self.bgConnection];
}

- (void)addDataModificationObserver:(id<TXLDatabaseObserver>)observer
{
    if (!observer || ![observer respondsToSelector:@selector(databaseModified:)])
        return;
    YapDatabase *database = self.uiConnection.database;
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(databaseModified:) name:YapDatabaseModifiedNotification object:database];
}

- (void)removeDataModificationObserver:(id<TXLDatabaseObserver>)observer
{
    if (!observer)
        return;
    YapDatabase *database = self.uiConnection.database;
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:YapDatabaseModifiedNotification object:database];
}

@end

const struct TXLDataLoaderKeys TXLDataLoaderKeys = {
    .legislatorListView = @"legislator.list",
    .legislatorListSearch = @"legislator.search",
};
