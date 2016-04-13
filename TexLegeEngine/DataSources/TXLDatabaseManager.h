//
//  TXLDatabaseManager.h
//  TexLege
//
//  Created by Gregory Combs on 6/25/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import Foundation;
@import YapDatabase;

@class RACSignal;

@interface TXLDatabaseManager : NSObject

/**
 *  Initialize a database manager with a database to created/found at the provided path.
 *
 *  @param databasePath A file system path to the new or existing sqlite database.
 *
 *  @return A new database manager instance.
 */
- (instancetype)initWithPath:(nullable NSString *)databasePath NS_DESIGNATED_INITIALIZER;

/**
 *  Return a new file system path to a (new/existing) sqlite database with the given name.
 *
 *  @param dbName  A short name to use as the suffix for a database file, as in `database-<dbName>-v<version>.sqlite`
 *  @param version A string to use as a version identifier for the new database path.
 *
 *  @return A file system path for the provided name.
 */
+ (NSString *)defaultDatabasePathWithName:(nullable NSString *)dbName version:(nullable NSString *)version;

/**
 *  Return the full file system path to the current database.
 */
@property (nonatomic,copy,readonly) NSString *databasePath;

/**
 *  Create a new connection instance to the database. You should consider connections to be 
 *  relatively heavy weight objects, because in terms of performance, you get a lot of bang 
 *  for your buck if you recycle your connections.  That said, a view controller should
 *  have one connection for UI-related reads and a separate background connection for
 *  asynchronous writes.
 *
 *  @return A new database connection instance.
 */
- (YapDatabaseConnection *)newDatabaseConnection;

- (RACSignal *)registerExtension:(YapDatabaseExtension *)extension withName:(NSString *)extensionName connection:(nullable YapDatabaseConnection *)connection;

- (RACSignal *)unregisterExtensionWithName:(NSString *)extensionName connection:(nullable YapDatabaseConnection *)connection;


@end
