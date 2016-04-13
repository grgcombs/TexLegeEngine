//
//  TXLTypeCheck.h
//  TexLege
//
//  Created by Gregory Combs on 3/30/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import Foundation;
@import UIKit;

#define TXLTrueIfClass(c,o...)          (o != NULL && \
                                         [(NSObject *)o isKindOfClass:[c class]])

#define TXLValueIfClass(c,o...)         ((c *)(TXLTrueIfClass(c,o) ? o : nil))

#define TXLTypeIsNull(o...)             ((o) == NULL || \
                                         TXLTrueIfClass(NSNull,o))

#define TXLTypeNumberOrNil(o...)        (TXLValueIfClass(NSNumber,o))
#define TXLTypeDecimalNumberOrNil(o...) (TXLValueIfClass(NSDecimalNumber,o))
#define TXLTypeImageOrNil(o...)         (TXLValueIfClass(UIImage,o))
#define TXLTypeDateOrNil(o...)          (TXLValueIfClass(NSDate,o))
#define TXLTypeDictionaryOrNil(o...)    (TXLValueIfClass(NSDictionary,o))
#define TXLTypeArrayOrNil(o...)         (TXLValueIfClass(NSArray,o))
#define TXLTypeURLOrNil(o...)           (TXLValueIfClass(NSURL,o))
#define TXLTypeStringOrNil(o...)        (TXLValueIfClass(NSString,o))

#define TXLTypeNonEmptyStringOrNil(o...)  ((TXLTrueIfClass(NSString,o) && \
                                           [((NSString *)o) length]) ? o : nil)

#define TXLTypeNonEmptyArrayOrNil(o...)   ((TXLTrueIfClass(NSArray,o) && \
                                           [((NSArray *)o) count]) ? o : nil)
