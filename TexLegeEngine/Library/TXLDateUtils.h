//
//  TXLDateUtils
//  TexLege
//
//  Created by Gregory Combs on 4/4/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXLDateUtils : NSObject

/**
 *  Formatter for the Sunlight date strings, assuming the time zone is UTC.
 *
 *  @return A date formatter.
 */
+ (NSDateFormatter *)sunlightUTCDateFormatter;

/**
 *  Formatter for Sunlight date strings, assuming the time zone is set to the state capitol.
 *
 *  @return A date formatter.
 */
+ (NSDateFormatter *)sunlightLocalDateFormatter;

@end
