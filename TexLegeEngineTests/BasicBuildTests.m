//
//  BasicBuildTests.m
//  BasicBuildTests
//
//  Created by Gregory Combs on 3/26/16.
//  Copyright © 2016 TexLege. All rights reserved.
//

#import <XCTest/XCTest.h>
@import Asterism;

@interface BasicBuildTests : XCTestCase

@end

@implementation BasicBuildTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testIndexOf {
    NSArray *array = @[@"Greg",@"Jim",@"Alex"];
    NSInteger index = ASTIndexOf(array, @"Alex");
    XCTAssertEqual(index, 2);
}

@end
