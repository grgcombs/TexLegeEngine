//
//  TXLDateFormatter.m
//  TexLege
//
//  Created by Gregory Combs on 4/4/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLDateUtils.h"
#import "TXLConstants.h"

@implementation TXLDateUtils

// Besure to always wrap this in a singleton
+ (NSDateFormatter *)newPosixFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    return dateFormatter;
}

+ (NSDateFormatter *)sunlightUTCDateFormatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;

    dispatch_once(&onceToken, ^{
        dateFormatter = [TXLDateUtils newPosixFormatter];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        dateFormatter.dateFormat = @"yyyyy-MM-dd HH:mm:ss"; // 2015-03-25 18:58:38
    });

    return dateFormatter;
}

+ (NSDateFormatter *)sunlightLocalDateFormatter
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;

    dispatch_once(&onceToken, ^{
        dateFormatter = [TXLDateUtils newPosixFormatter];
        dateFormatter.dateFormat = @"yyyyy-MM-dd HH:mm:ss"; // 2015-03-25 18:58:38
    });
    dateFormatter.timeZone = TXLCapitolTimeZone;

    return dateFormatter;
}

@end
