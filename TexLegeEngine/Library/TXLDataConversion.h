//
//  TXLDataConversion.h
//  TexLege
//
//  Created by Gregory Combs on 4/3/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

@import Foundation;
@import Overcoat.OVCResponse;

NSDictionary * TXLMapListResponseToDictWithKey(OVCResponse *response, NSString *primaryKey);

NSDictionary * TXLMapListResponseToGroupedDictWithKey(OVCResponse *response, NSString *groupByKey);

NSDictionary * TXLMapListResponseToGroupedDictWithNestedKeys(OVCResponse *response, NSString *groupOneKey, NSString *groupTwoKey);

//id TXLMapValidDetailsResponse(OVCResponse *response, Class expectedClass);

#define TXLMapValidDetailsResponseToClass(theResponse,theClass) (TXLValueIfClass(theClass,[TXLValueIfClass(OVCResponse,theResponse) result]))
