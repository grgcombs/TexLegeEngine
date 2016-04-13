//
//  TXLLegislator.m
//  TexLege
//
//  Created by Gregory Combs on 4/3/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import "TXLLegislator.h"
#import "TXLRole.h"
#import "TXLOffice.h"
#import "TXLDateUtils.h"

#define txlPropToJSON(KEY,PATH) txlMeta_KEY(TXLLegislator,KEY): PATH

@interface TXLLegislator ()

txlMeta_props_copyrw_def(NSString,capFax,capOffice,chamber,district,email,firstName,fullName,lastInitial,lastName,legId,middleName,nimspId,nimspCandidateId,party,preferredName,suffixes,transparencyDataId,twitter,boundaryId);

txlMeta_props_copyrw_def(NSNumber,partisanIndex);

txlMeta_props_copyrw_def(NSURL,bioUrl,photoUrl,url);

txlMeta_props_copyrw_def(NSDate,updatedAt);

txlMeta_props_copyrw_def(NSArray,offices,roles,oldIds);

@property (nonatomic,assign) TXLLegislatorParty partyId;

@property (nonatomic,assign) TXLMetadataChamber chamberId;

@property (nonatomic,assign) NSInteger localizedCollationSection;

@end

@implementation TXLLegislator

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             txlPropToJSON(capFax,@"cap_fax"),
             txlPropToJSON(capOffice,@"cap_office"),
             txlPropToJSON(chamber,@"chamber"),
             txlPropToJSON(district,@"district"),
             txlPropToJSON(email,@"email"),
             txlPropToJSON(firstName,@"first_name"),
             txlPropToJSON(fullName,@"full_name"),
             txlPropToJSON(lastInitial,@"last_initial"),
             txlPropToJSON(lastName,@"last_name"),
             txlPropToJSON(legId,@"leg_id"),
             txlPropToJSON(middleName,@"middle_name"),
             txlPropToJSON(nimspId, @"nimsp_id"),
             txlPropToJSON(nimspCandidateId, @"nimsp_candidate_id"),
             txlPropToJSON(party,@"party"),
             txlPropToJSON(preferredName,@"preferred_name"),
             txlPropToJSON(suffixes,@"suffixes"),
             txlPropToJSON(transparencyDataId,@"transparency_data_id"),
             txlPropToJSON(twitter,@"twitter"),
             txlPropToJSON(boundaryId, @"boundary_id"),
             txlPropToJSON(bioUrl,@"bio_url"),
             txlPropToJSON(url,@"url"),
             txlPropToJSON(photoUrl,@"photo_url"),
             txlPropToJSON(partisanIndex,@"partisan_index"),
             txlPropToJSON(partyId,@"party_id"),
             txlPropToJSON(updatedAt,@"updated_at"),
             txlPropToJSON(offices,@"offices"),
             txlPropToJSON(roles,@"roles"),
             txlPropToJSON(oldIds, @"all_ids"),
//             txlPropToJSON(nameComponents, @"name_components"),
//             txlPropToJSON(localizedCollationSection, @"collation_section"),
             };
}

/*
+ (MTLPropertyStorage)storageBehaviorForPropertyWithKey:(NSString *)propertyKey
{
    if ([propertyKey isEqualToString:txlMeta_KEY(TXLLegislator, nameComponents)] ||
        [propertyKey isEqualToString:txlMeta_KEY(TXLLegislator, localizedCollationSection)])
    {
        return MTLPropertyStorageTransitory;
    }
    return [[self superclass] storageBehaviorForPropertyWithKey:propertyKey];
}*/

- (void)setChamber:(NSString *)chamber
{
    chamber = [TXLTypeNonEmptyStringOrNil(chamber) copy];
    _chamber = chamber;
    if (!chamber)
        return;

    if ([chamber isEqualToString:txlMeta_KEY(TXLMetadataChamber, lower)])
        self.chamberId = TXLMetadataChamberLower;
    else if ([chamber isEqualToString:txlMeta_KEY(TXLMetadataChamber, upper)])
        self.chamberId = TXLMetadataChamberUpper;
    else if ([chamber isEqualToString:txlMeta_KEY(TXLMetadataChamber, joint)])
        self.chamberId = TXLMetadataChamberJoint;
    else
        self.chamberId = TXLMetadataChamberUpper;
}

- (void)setLastName:(NSString *)lastName
{
    lastName = [TXLTypeStringOrNil(lastName) copy];
    _lastName = lastName;

    if (TXLTypeStringOrNil(_lastInitial))
        return;
    NSString *lastInitial = nil;
    if (lastName.length)
    {
        NSRange characterRange = [lastName rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 1)];
        if (characterRange.length > 0
            && characterRange.location != NSNotFound)
        {
            lastInitial = [lastName substringWithRange:characterRange];
        }
    }
    [self setLastInitial:lastInitial];
}

- (void)setLastInitial:(NSString *)lastInitial
{
    lastInitial = [TXLTypeNonEmptyStringOrNil(lastInitial) copy];
    if (!lastInitial)
        lastInitial = @" ";
    _lastInitial = lastInitial;

    NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:lastInitial collationStringSelector:@selector(description)];

    // for search icon section, we offset the default section number
    //    section++;

    self.localizedCollationSection = section;
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    if (!TXLTypeNonEmptyStringOrNil(key))
        return nil;

    txlMeta_ofks_keys(TXLLegislator,capFax,capOffice,chamber,district,email,firstName,fullName,lastInitial,lastName,legId,middleName,nimspId,nimspCandidateId,party,preferredName,suffixes,transparencyDataId,twitter,boundaryId);
    txlMeta_ofks_keys(TXLLegislator,partisanIndex);
    txlMeta_ofks_keys(TXLLegislator,bioUrl,photoUrl,url);
    txlMeta_ofks_keys(TXLLegislator,updatedAt);
    txlMeta_ofks_keys(TXLLegislator,offices,roles,oldIds);

    if ([key isEqualToString:txlMeta_KEY(TXLLegislator,partyId)])
        return @(self.partyId);

    if ([key isEqualToString:txlMeta_KEY(TXLLegislator,chamberId)])
        return @(self.chamberId);

    if ([key isEqualToString:txlMeta_KEY(TXLLegislator, localizedCollationSection)])
        return @(self.localizedCollationSection);

    txlMeta_ofks_header

    txlMeta_ofks_footer
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    txlMeta_soks_header

    txlMeta_soks_string_keys(TXLLegislator,capFax,capOffice,chamber,district,email,firstName,fullName,lastInitial,lastName,legId,middleName,nimspId,nimspCandidateId,party,preferredName,suffixes,transparencyDataId,twitter,boundaryId);
    txlMeta_soks_number_keys(TXLLegislator,partisanIndex);
    txlMeta_soks_url_keys(TXLLegislator,bioUrl,photoUrl,url);
    txlMeta_soks_date_keys(TXLLegislator,updatedAt);
    txlMeta_soks_array_keys(TXLLegislator,offices,roles,oldIds);

    if ([key isEqualToString:txlMeta_KEY(TXLLegislator, localizedCollationSection)])
    {
        self.localizedCollationSection = [object integerValue];
        return;
    }

    if ([key isEqualToString:txlMeta_KEY(TXLLegislator, partyId)])
    {
        switch ((TXLLegislatorParty)[object unsignedIntValue])
        {
            case TXLLegislatorDemocratParty:
                self.partyId = TXLLegislatorDemocratParty;
                break;
            case TXLLegislatorRepublicanParty:
                self.partyId = TXLLegislatorRepublicanParty;
                break;
            case TXLLegislatorUnknownParty:
            default:
                self.partyId = TXLLegislatorUnknownParty;
                break;
        }
        return;
    }

    if ([key isEqualToString:txlMeta_KEY(TXLLegislator, chamberId)])
    {
        switch ((TXLMetadataChamber)[object unsignedIntValue])
        {
            case TXLMetadataChamberLower:
                self.chamberId = TXLMetadataChamberLower;
                break;
            case TXLMetadataChamberUpper:
                self.chamberId = TXLMetadataChamberUpper;
                break;
            case TXLMetadataChamberJoint:
                self.chamberId = TXLMetadataChamberJoint;
                break;
            case TXLMetadataChamberUnknown:
            default:
                self.chamberId = TXLMetadataChamberUnknown;
                break;
        }
        return;
    }

    txlMeta_soks_footer
}

- (NSString *)shortDescription
{
    return [NSString stringWithFormat:@"%@: %@ (%@)", self.legId, self.fullName, self.chamber];
}

- (NSPersonNameComponents *)nameComponents
{
    NSString *first = self.firstName;
    NSString *last = self.lastName;

    if (!first.length || !last.length)
        return nil;

    NSPersonNameComponents *nameComponents = [[NSPersonNameComponents alloc] init];

    nameComponents.givenName = first;
    nameComponents.familyName = last;

    NSString *middle = self.middleName;
    if (middle)
        nameComponents.middleName = middle;

    NSString *suffixes = self.suffixes;
    if (suffixes)
        nameComponents.nameSuffix = suffixes;

    switch (self.chamberId) {
        case TXLMetadataChamberLower:
            nameComponents.namePrefix = NSLocalizedString(@"Rep.", @"Abbreviation for Representative");
            break;

        case TXLMetadataChamberUpper:
            nameComponents.namePrefix = NSLocalizedString(@"Sen.", @"Abbreviation for Senator");
            break;

        case TXLMetadataChamberUnknown:
        case TXLMetadataChamberJoint:
            break;
}

    return nameComponents;
}

- (NSComparisonResult)compare:(TXLLegislator *)other
{
    NSComparisonResult result = NSOrderedAscending;

    if (!TXLValueIfClass(TXLLegislator, other))
        return result;

    result = [@(self.localizedCollationSection) compare:@(other.localizedCollationSection)];
    if (result != NSOrderedSame)
        return result;

    for (NSString *componentKey in @[NSStringFromSelector(@selector(lastName)),
                                     NSStringFromSelector(@selector(firstName)),
                                     NSStringFromSelector(@selector(middleName))])
    {
        NSString *this = self[componentKey];
        if (!this.length)
            continue;
        NSString *that = other[componentKey];
        result = [this localizedCaseInsensitiveCompare:that];
        if (result == NSOrderedSame)
            continue;
        break;
    }

    //if (result == NSOrderedSame) // need a tie-breaker
    //    result = [@(self.chamberId) compare:@(other.chamberId)];

    return result;
}

#pragma mark - Transformers

+ (NSValueTransformer *)rolesJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TXLRole class]];
}

+ (NSValueTransformer *)officesJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TXLOffice class]];
}

+ (NSValueTransformer *)bioUrlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)photoUrlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)urlJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)updatedAtJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] dateFromString:value];
    } reverseBlock:^id(NSDate *value, BOOL *success, NSError **error) {
        return [[TXLDateUtils sunlightUTCDateFormatter] stringFromDate:value];
    }];
}

+ (NSValueTransformer *)partyIdJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @0: @(TXLLegislatorUnknownParty),
                                                                           @1: @(TXLLegislatorDemocratParty),
                                                                           @2: @(TXLLegislatorRepublicanParty),
                                                                           }
                                                            defaultValue: @(TXLLegislatorUnknownParty)
                                                     reverseDefaultValue: @0];
}

@end

const struct TXLLegislatorKeys TXLLegislatorKeys = {
    txlMeta_struct_items_impl(capFax,capOffice,chamber,district,email,firstName,fullName,lastInitial,lastName,legId,middleName,nimspId,nimspCandidateId,party,preferredName,suffixes,transparencyDataId,twitter,boundaryId)
    txlMeta_struct_items_impl(partisanIndex,partyId,chamberId)
    txlMeta_struct_items_impl(bioUrl,photoUrl,url)
    txlMeta_struct_items_impl(updatedAt)
    txlMeta_struct_items_impl(offices,roles,oldIds)
    txlMeta_struct_items_impl(nameComponents)
};
