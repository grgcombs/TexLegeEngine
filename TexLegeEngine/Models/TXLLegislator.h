//
//  TXLLegislator.h
//  TexLege
//
//  Created by Gregory Combs on 4/3/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLModel.h"
#import "TXLMetadata.h"

typedef NS_ENUM(uint8_t, TXLLegislatorParty) {
    TXLLegislatorUnknownParty,
    TXLLegislatorDemocratParty,
    TXLLegislatorRepublicanParty,
};

@interface TXLLegislator : TXLModel<TXLOldModelIdentifiers>

txlMeta_props_copyro_def(NSString,capFax,capOffice,chamber,district,email,firstName,fullName,lastInitial,lastName,legId,middleName,nimspId,nimspCandidateId,party,preferredName,suffixes,transparencyDataId,twitter,boundaryId)

txlMeta_props_copyro_def(NSNumber,partisanIndex)

txlMeta_props_copyro_def(NSURL,bioUrl,photoUrl,url)

txlMeta_props_copyro_def(NSDate,updatedAt)

txlMeta_props_copyro_def(NSArray,offices,roles,oldIds)

@property (nonatomic,copy,readonly) NSPersonNameComponents *nameComponents;

@property (nonatomic,assign,readonly) TXLLegislatorParty partyId;

@property (nonatomic,assign,readonly) TXLMetadataChamber chamberId;

@property (nonatomic,assign,readonly) NSInteger localizedCollationSection;

+ (BOOL)supportsSecureCoding;

- (NSComparisonResult)compare:(TXLLegislator *)other;

@end

extern const struct TXLLegislatorKeys {
    txlMeta_struct_items_def(capFax,capOffice,chamber,district,email,firstName,fullName,lastInitial,lastName,legId,nimspId,nimspCandidateId,middleName,party,preferredName,suffixes,transparencyDataId,twitter,boundaryId)
    txlMeta_struct_items_def(partisanIndex,partyId,chamberId)
    txlMeta_struct_items_def(bioUrl,photoUrl,url)
    txlMeta_struct_items_def(updatedAt)
    txlMeta_struct_items_def(offices,roles,oldIds)
    txlMeta_struct_items_def(nameComponents,localizedCollationSection)
} TXLLegislatorKeys;

