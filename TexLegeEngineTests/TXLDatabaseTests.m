//
//  TXLDatabaseTests.m
//  TexLege
//
//  Created by Gregory Combs on 6/25/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import XCTest;
@import YapDatabase;
#import "TXLTypeCheck.h"
#import "TXLDatabaseManager.h"

@interface TXLDatabaseTests : XCTestCase

@property (nonatomic,copy) NSString *databaseName;
@property (nonatomic,copy,readonly) NSString *databasePath;
@property (nonatomic,strong) TXLDatabaseManager *dbManager;

@end

@implementation TXLDatabaseTests

- (void)setUp
{
    [super setUp];

    // YapDB doesn't like it when Xcode runs setup more than once with the same path name, so we randomize it
    _databaseName = NSStringFromClass([self class]);
    _databasePath = [[TXLDatabaseManager defaultDatabasePathWithName:_databaseName version:[self randomLetters:8]] copy];
    NSLog(@"Database path is: %@", _databasePath);

    _dbManager = [[TXLDatabaseManager alloc] initWithPath:_databasePath];
}

- (void)tearDown
{
    NSString *prefix = [@"database-" stringByAppendingString:_databaseName];
    NSString *directoryPath = [_databasePath stringByDeletingLastPathComponent];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = [fileManager contentsOfDirectoryAtPath:directoryPath error:NULL];
    for (NSString *path in paths)
    {
        if ([path.lastPathComponent hasPrefix:prefix])
        {
            NSError *error = nil;
            NSString *filePath = [directoryPath stringByAppendingPathComponent:path];
            if (![fileManager removeItemAtPath:filePath error:&error] || error)
                NSLog(@"Error trashing database file at %@: %@", filePath, error);
        }
    }

    [super tearDown];
}

- (void)testDatabaseManagerInitializes
{
    XCTAssertNotNil(_dbManager, @"Manager should initialize");

    NSString *foundPath = _dbManager.databasePath;
    XCTAssertNotNil(foundPath, @"Manager should have a database path");

    XCTAssertEqualObjects(foundPath, _databasePath, @"The database paths should be the same");

    YapDatabaseConnection *connection = [_dbManager newDatabaseConnection];
    XCTAssertNotNil(connection, @"Should receive a new database connection instance");
}

- (void)testDatabaseStoresData
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Test write/read database entries"];

    YapDatabaseConnection *bgConnection = [_dbManager newDatabaseConnection];
    YapDatabaseConnection *uiConnection = [_dbManager newDatabaseConnection];

    static const uint32_t numberOfRecords = 2500;
    static const uint32_t lengthOfString = 2000;
    static NSString * const collectionKey = @"randomLetters";

    __block BOOL hasFinishedWriting = NO;

    [bgConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {

        for (uint32_t i = 0; i < numberOfRecords; i++)
        {
            NSString *key = [NSString stringWithFormat:@"%d", i];
            NSString *string = [self randomLetters:lengthOfString];
            [transaction setObject:string forKey:key inCollection:collectionKey];
        }

    } completionBlock:^{

        hasFinishedWriting = YES;

        __block BOOL didFail = NO;

        [uiConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {

            NSUInteger foundCount = [transaction numberOfKeysInCollection:collectionKey];
            
            if (foundCount != numberOfRecords)
            {
                didFail = YES;
                return;
            }

            [transaction enumerateKeysAndObjectsInCollection:collectionKey usingBlock:^(NSString *key, NSString *object, BOOL *stop) {

                BOOL isKeyString = (TXLTypeNonEmptyStringOrNil(key) != NULL);
                BOOL isObjectString = (TXLTypeNonEmptyStringOrNil(object) != NULL);

                if (!isKeyString || !isObjectString)
                {
                    didFail = YES;
                    *stop = YES;
                }
            }];

        } completionBlock:^{

            XCTAssertTrue(hasFinishedWriting, @"Write database failed");
            XCTAssertFalse(didFail, @"Read database failed");
            if (hasFinishedWriting && !didFail)
                [expectation fulfill];
        }];
    }];


    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error)
            XCTFail(@"Read database failed with error: %@", error);
    }];
}

- (NSString *)randomLetters:(uint32_t)length
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    NSUInteger alphabetLength = [alphabet length];

    NSMutableString *result = [NSMutableString stringWithCapacity:length];

    for (uint32_t i = 0; i < length; i++)
    {
        uint32_t randomIndex = arc4random_uniform((uint32_t)alphabetLength);
        unichar c = [alphabet characterAtIndex:(NSUInteger)randomIndex];

        [result appendFormat:@"%C", c];
    }
    
    return result;
}

@end
