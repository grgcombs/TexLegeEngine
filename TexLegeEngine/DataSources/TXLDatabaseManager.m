//
//  TXLDatabaseManager.m
//  TexLege
//
//  Created by Gregory Combs on 6/25/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLDatabaseManager.h"
#import "TXLConstants.h"
#import "TexLege-Environment.h"

@interface TXLDatabaseManager ()
@property (nonatomic,strong,readonly) YapDatabase *database;
@end

typedef RACDisposable*(^TXLRacSignalBlock)(id<RACSubscriber> subscriber);


@implementation TXLDatabaseManager

- (instancetype)initWithPath:(NSString *)databasePath
{
    self = [super init];
    if (self)
    {
        if (!databasePath.length)
            databasePath = [[self class] defaultDatabasePathWithName:nil version:nil];
        _database = [[YapDatabase alloc] initWithPath:[databasePath copy]];
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithPath:nil];
    return self;
}

- (YapDatabaseConnection *)newDatabaseConnection
{
    if (!_database)
        return nil;

    return [_database newConnection];
}

- (NSString *)databasePath
{
    return _database.databasePath;
}

+ (NSString *)defaultDatabasePathWithName:(NSString *)dbName version:(NSString *)version
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? paths[0] : NSTemporaryDirectory();

    if (!dbName.length)
        dbName = TXLCommonConfig.databaseName;
    if (!version.length)
        version = TXLCommonConfig.databaseVersion;
    if (version.length > 1 && [version hasPrefix:@"v"])
        version = [version substringFromIndex:1];

    NSString *databaseName = [NSString stringWithFormat:@"database-%@-v%@.sqlite", dbName, version];
    
    return [baseDir stringByAppendingPathComponent:databaseName];
}

+ (NSError *)newRegistrationErrorForExtension:(NSString *)extensionName databasePath:(NSString *)databasePath registering:(BOOL)isRegistering
{
    NSString *localization = nil;
    NSString *domain = nil;
    if (isRegistering)
    {
        localization = NSLocalizedString(@"Error registering %@ extension on database - (%@)!", @"Error Message");
        domain = @"db.extension.register";
    }
    else
    {
        localization = NSLocalizedString(@"Error unregistering %@ extension on database - (%@)!", @"Error Message");
        domain = @"db.extension.unregister";
    }

    NSString *errorMessage = [NSString stringWithFormat:localization, extensionName, databasePath];
    DDLogError(@"%@", errorMessage);
    return [NSError errorWithDomain:domain code:-100 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
}

- (RACSignal *)registerExtension:(YapDatabaseExtension *)extension withName:(NSString *)extensionName connection:(YapDatabaseConnection *)connection
{
    NSAssert(TXLTypeNonEmptyStringOrNil(extensionName), @"Cannot register an extension with an invalid name");

    YapDatabase *database = self.database;
    NSString *dbPath = database.databasePath;

    if (!database ||
        !extension ||
        !extensionName.length)
    {
        NSError *error = [TXLDatabaseManager newRegistrationErrorForExtension:extensionName databasePath:dbPath registering:YES];
        return [RACSignal error:error];
    }

    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        if (!database || !extension || !extensionName.length)
        {
            NSError *error = [TXLDatabaseManager newRegistrationErrorForExtension:extensionName databasePath:dbPath registering:YES];
            [subscriber sendError:error];
            return [RACDisposable disposableWithBlock:^{}];
        }

        NSDictionary *successInfo = @{@"view": extensionName,
                                      @"registering": @YES,
                                      @"ready": @YES};

        RACDisposable *onDeallocateSignal = [RACDisposable disposableWithBlock:^{}];

        NSDictionary *registeredExtensions = [database registeredExtensions];
        if (extension.registeredName != nil ||
            registeredExtensions[extensionName] != nil)
        {
            // Can't register an extension that's already registered

            [subscriber sendNext:successInfo];
            [subscriber sendCompleted];

            return onDeallocateSignal;
        }

        dispatch_queue_t completionQueue = dispatch_get_main_queue();
        [database asyncRegisterExtension:extension withName:extensionName connection:connection completionQueue:completionQueue completionBlock:^(BOOL ready) {

            if (!ready)
            {
                NSError *error = [TXLDatabaseManager newRegistrationErrorForExtension:extensionName databasePath:dbPath registering:YES];
                [subscriber sendError:error];
            }
            else
            {
                [subscriber sendNext:successInfo];
                [subscriber sendCompleted];

                DDLogDebug(@"Finished registering %@ extension", extensionName);
            }
        }];

        return onDeallocateSignal;

    }] setNameWithFormat:@"%@ -registerExtension: %@", self.class, extensionName];
}

- (RACSignal *)unregisterExtensionWithName:(NSString *)extensionName connection:(YapDatabaseConnection *)connection
{
    NSAssert(TXLTypeNonEmptyStringOrNil(extensionName), @"Cannot unregister an extension with an invalid name");

    YapDatabase *database = self.database;
    NSString *dbPath = database.databasePath;

    if (!database ||
        !extensionName.length)
    {
        NSError *error = [TXLDatabaseManager newRegistrationErrorForExtension:extensionName databasePath:dbPath registering:NO];
        return [RACSignal error:error];
    }

    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        dispatch_queue_t completionQueue = dispatch_get_main_queue();
        [database asyncUnregisterExtensionWithName:extensionName connection:connection completionQueue:completionQueue completionBlock:^{
            NSDictionary *successInfo = @{@"view": extensionName,
                                          @"registering": @NO};

            [subscriber sendNext:successInfo];
            [subscriber sendCompleted];
        }];

        return [RACDisposable disposableWithBlock:^{}];

    }] setNameWithFormat:@"%@ -unregisterExtension: %@", self.class, extensionName];
}

@end
