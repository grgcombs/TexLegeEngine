//
//  TexLegeEngine.m
//  TexLegeEngine
//
//  Created by Gregory Combs on 6/16/16.
//  Copyright © 2016 TexLege. All rights reserved.
//

#import "TexLegeEngine.h"

static TexLegeEngine *sharedEngine;

@interface TexLegeEngine()
@property (atomic,assign) TXLPrivateConfigType privateConfig;
@end

@implementation TexLegeEngine

- (instancetype)initWithPrivateConfig:(TXLPrivateConfigType)privateConfig
{
    if (!TXLPrivateConfigIsValid(privateConfig))
        return nil;
    self = [super init];
    if (!self)
        return nil;
    _privateConfig = privateConfig;
    _dataLoader = [[TXLDataLoader alloc] initWithClientConfig:privateConfig];
    return self;
}

+ (instancetype)instanceWithPrivateConfig:(TXLPrivateConfigType)privateConfig
{
    if (!TXLPrivateConfigIsValid(privateConfig))
        return nil;

    if (sharedEngine
        && TXLPrivateConfigsAreEqual(privateConfig, sharedEngine.privateConfig))
    {
        return sharedEngine;
    }

    sharedEngine = [[TexLegeEngine alloc] initWithPrivateConfig:privateConfig];

    return sharedEngine;
}

+ (instancetype)instance
{
    if (sharedEngine)
        return sharedEngine;

    NSAssert2(sharedEngine != NULL, @"There is no shared %@.  Create a fresh instance and provide configuration settings using %@", NSStringFromClass(self), NSStringFromSelector(@selector(instanceWithPrivateConfig:)));
    return nil;
}

@end
