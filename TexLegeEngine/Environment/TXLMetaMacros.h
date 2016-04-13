//
//  TXLMetaMacros.h
//
//  TexLege
//  https://github.com/sunlightlabs/TexLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
// Thanks to Rodrigo Lima for turning me on to metamacros!
//

#import <ReactiveCocoa/metamacros.h>
#import "TXLTypeCheck.h"

// GENERIC KEYS/ RELATIONS ---------------------------------------------------------------------------------------------
#define txlMeta_struct_item_def(INDEX,ARG) __unsafe_unretained NSString * ARG;
#define txlMeta_struct_item_impl(INDEX,ARG) .ARG = @metamacro_stringify(ARG) ,

#define txlMeta_struct_items_def(...)    \
    metamacro_foreach(txlMeta_struct_item_def,, __VA_ARGS__)

#define txlMeta_struct_def(NAME, NAME_MACRO, ...)               \
extern const struct NAME_MACRO(NAME) {                          \
    txlMeta_struct_items_def(__VA_ARGS__)                       \
} NAME_MACRO(NAME);

#define txlMeta_struct_items_impl(...)    \
    metamacro_foreach(txlMeta_struct_item_impl,, __VA_ARGS__)

#define txlMeta_struct_impl(NAME, NAME_MACRO, ...)              \
const struct NAME_MACRO(NAME) NAME_MACRO(NAME) = {              \
    txlMeta_struct_items_impl(__VA_ARGS__)                      \
};

// KEYS
#define txlMeta_struct_keys_name(NAME) metamacro_concat(NAME, Keys)
#define txlMeta_keys_def(NAME,...)     txlMeta_struct_def(NAME, txlMeta_struct_keys_name, __VA_ARGS__)
#define txlMeta_keys_impl(NAME,...)    txlMeta_struct_impl(NAME, txlMeta_struct_keys_name, __VA_ARGS__)

// RELATIONS
#define txlMeta_struct_relationshipkeys_name(NAME) metamacro_concat(NAME, RelationshipKeys)
#define txlMeta_relations_def(NAME,...)  txlMeta_struct_def(NAME,txlMeta_struct_relationshipkeys_name,__VA_ARGS__)
#define txlMeta_relations_impl(NAME,...) txlMeta_struct_impl(NAME,txlMeta_struct_relationshipkeys_name,__VA_ARGS__)


// HELPER --------------------------------------------------------------------------------------------------------------
#define txlMeta_KEY(NAME,KEY)           txlMeta_struct_keys_name(NAME).KEY
#define txlMeta_RELATION(NAME,RELATION) txlMeta_struct_relationshipkeys_name(NAME).RELATION

#define txlMeta_KEY_VALUE(KEY)          metamacro_concat(KEY,Value)
#define txlMeta_KEY_SETVALUE(UPPER_KEY) metamacro_concat(set,metamacro_concat(UPPER_KEY,Value))

#define txlMeta_set_class(INDEX,KEY) KEY.class,
#define txlMeta_set_with_classes(...) \
[NSSet setWithObjects: metamacro_foreach(txlMeta_set_class,,__VA_ARGS__) nil]


// COPY_WITH_ZONE STUFF ------------------------------------------------------------------------------------------------
#define txlMeta_cwz_item_assign(INDEX,KEY) if (self.KEY) copy.KEY = self.KEY;
#define txlMeta_cwz_item_copy(INDEX,KEY)   if (self.KEY) copy.KEY = [self.KEY copyWithZone:zone];
#define txlMeta_cwz_item_mutcopy(INDEX,KEY)   if (self.KEY) copy.KEY = [self.KEY mutableCopyWithZone:zone];

#define txlMeta_cwz_assign_vars(...) metamacro_foreach(txlMeta_cwz_item_assign,,__VA_ARGS__)
#define txlMeta_cwz_copy_vars(...)  metamacro_foreach(txlMeta_cwz_item_copy,,__VA_ARGS__)
#define txlMeta_cwz_mutcopy_vars(...)  metamacro_foreach(txlMeta_cwz_item_mutcopy,,__VA_ARGS__)

#define txlMeta_cwz_header(NAME)    \
NAME *copy = [super copyWithZone:zone]; \
if (copy) {

#define txlMeta_mcwz_header(NAME)    \
NAME *copy = [super mutableCopyWithZone:zone]; \
if (copy) {


#define txlMeta_cwz_footer \
} return copy;


// INIT_WITH_CODER STUFF -----------------------------------------------------------------------------------------------

//--keys
#define txlMeta_iwc_key(NAME,CLASSES,KEY)                   \
if ([decoder containsValueForKey:txlMeta_KEY(NAME,KEY)]) {  \
self.KEY = [decoder decodeObjectOfClasses:self.CLASSES      \
forKey:txlMeta_KEY(NAME,KEY)];                          \
}

#define txlMeta_iwc_key_string(INDEX,CONTEXT,KEY)     txlMeta_iwc_key(CONTEXT,allowedString,KEY)
#define txlMeta_iwc_key_collection(INDEX,CONTEXT,KEY) txlMeta_iwc_key(CONTEXT,allowedCollection,KEY)
#define txlMeta_iwc_key_array(INDEX,CONTEXT,KEY)      txlMeta_iwc_key(CONTEXT,allowedCollection,KEY)
#define txlMeta_iwc_key_dictionary(INDEX,CONTEXT,KEY) txlMeta_iwc_key(CONTEXT,allowedCollection,KEY)
#define txlMeta_iwc_key_number(INDEX,CONTEXT,KEY)     txlMeta_iwc_key(CONTEXT,allowedNumber,KEY)
#define txlMeta_iwc_key_decimal(INDEX,CONTEXT,KEY)    txlMeta_iwc_key(CONTEXT,allowedDecimal,KEY)
#define txlMeta_iwc_key_date(INDEX,CONTEXT,KEY)       txlMeta_iwc_key(CONTEXT,allowedDate,KEY)
#define txlMeta_iwc_key_sort(INDEX,CONTEXT,KEY)       txlMeta_iwc_key(CONTEXT,allowedSort,KEY)

#define txlMeta_iwc_string_keys(NAME,...)       metamacro_foreach_cxt(txlMeta_iwc_key_string,,NAME,__VA_ARGS__)
#define txlMeta_iwc_dictionary_keys(NAME,...)   metamacro_foreach_cxt(txlMeta_iwc_key_dictionary,,NAME,__VA_ARGS__)
#define txlMeta_iwc_array_keys(NAME,...)        metamacro_foreach_cxt(txlMeta_iwc_key_array,,NAME,__VA_ARGS__)
#define txlMeta_iwc_collection_keys(NAME,...)   metamacro_foreach_cxt(txlMeta_iwc_key_collection,,NAME,__VA_ARGS__)
#define txlMeta_iwc_number_keys(NAME,...)       metamacro_foreach_cxt(txlMeta_iwc_key_number,,NAME,__VA_ARGS__)
#define txlMeta_iwc_decimal_keys(NAME,...)      metamacro_foreach_cxt(txlMeta_iwc_key_decimal,,NAME,__VA_ARGS__)
#define txlMeta_iwc_date_keys(NAME,...)         metamacro_foreach_cxt(txlMeta_iwc_key_date,,NAME,__VA_ARGS__)
#define txlMeta_iwc_sort_keys(NAME,...)         metamacro_foreach_cxt(txlMeta_iwc_key_sort,,NAME,__VA_ARGS__)

//--relations
#define txlMeta_iwc_relation_dictionary(NAME,BASE_CLASS,RELATION)                                   \
if ([decoder containsValueForKey:txlMeta_RELATION(NAME,RELATION)]) {                                \
NSSet *allowed = txlMeta_set_with_classes(NSDictionary,BASE_CLASS);                             \
self.RELATION = [decoder decodeObjectOfClasses:allowed forKey:txlMeta_RELATION(NAME,RELATION)]; \
}

#define txlMeta_iwc_dictionary_relations(NAME,BASE_CLASS,...)   \
metamacro_foreach_cxt(txlMeta_iwc_relation_dictionary,,BASE_CLASS,__VA_ARGS__)

//--header / footer
#define txlMeta_iwc_header          \
self = [super initWithCoder:decoder];   \
if (!self) return self;                 \
@try {

#define txlMeta_iwc_footer \
} @catch (NSException *exception) { TXLErrorLog(@"Exception while decoding plist: %@", exception); } \
return self;


// ENCODE_WITH_CODER ---------------------------------------------------------------------------------------------------

//--keys
#define txlMeta_ewc_key(INDEX,NAME,KEY)           if (self.KEY) [encoder encodeObject:self.KEY forKey:txlMeta_KEY(NAME,KEY)];
#define txlMeta_ewc_keys(NAME,...)      metamacro_foreach_cxt(txlMeta_ewc_key,,NAME,__VA_ARGS__)

//--relations
#define txlMeta_ewc_relation(INDEX,NAME,RELATION) if (self.RELATION) [encoder encodeObject:self.RELATION forKey:txlMeta_RELATION(NAME,RELATION)];
#define txlMeta_ewc_relations(NAME,...) metamacro_foreach_cxt(txlMeta_ewc_relation,,NAME,__VA_ARGS__)

//--header / footer
#define txlMeta_ewc_header [super encodeWithCoder:encoder];


// OBJECT_FOR_KEYED_SUBSCRIPT ------------------------------------------------------------------------------------------

//--keys
#define txlMeta_ofks_key(INDEX,NAME,KEY)            if ([key isEqualToString:txlMeta_KEY(NAME,KEY)]) return self.KEY;
#define txlMeta_ofks_keys(NAME,...)      metamacro_foreach_cxt(txlMeta_ofks_key,,NAME,__VA_ARGS__)

//--relations
#define txlMeta_ofks_relation(INDEX,NAME,RELATION)  if ([key isEqualToString:txlMeta_RELATION(NAME,RELATION)]) return self.RELATION;
#define txlMeta_ofks_relations(NAME,...) metamacro_foreach_cxt(txlMeta_ofks_relation,,NAME,__VA_ARGS__)

//--header / footer
#define txlMeta_ofks_header                     \
id object = [super objectForKeyedSubscript:key];    \
if (object) return object;                          \
if (!TXLTypeNonEmptyStringOrNil(key)) return nil;

#define txlMeta_ofks_footer return nil;


// SET_OBJECT_FOR_KEYED_SUBSCRIPT --------------------------------------------------------------------------------------

//--generic
#define txlMeta_soks_key_or_relation(KEY_OR_RELATION,NAME,HELPER,KEY)   \
if ([key isEqualToString:KEY_OR_RELATION(NAME,KEY)]) {                      \
self.KEY = HELPER(object);                                              \
return;                                                                 \
}

//--keys
#define txlMeta_soks_key_string(INDEX,CONTEXT,KEY)     txlMeta_soks_key_or_relation(txlMeta_KEY,CONTEXT,TXLTypeStringOrNil,KEY)
#define txlMeta_soks_key_dictionary(INDEX,CONTEXT,KEY) txlMeta_soks_key_or_relation(txlMeta_KEY,CONTEXT,TXLTypeDictionaryOrNil,KEY)
#define txlMeta_soks_key_array(INDEX,CONTEXT,KEY)      txlMeta_soks_key_or_relation(txlMeta_KEY,CONTEXT,TXLTypeArrayOrNil,KEY)
#define txlMeta_soks_key_number(INDEX,CONTEXT,KEY)     txlMeta_soks_key_or_relation(txlMeta_KEY,CONTEXT,TXLTypeNumberOrNil,KEY)
#define txlMeta_soks_key_decimal(INDEX,CONTEXT,KEY)    txlMeta_soks_key_or_relation(txlMeta_KEY,CONTEXT,TXLTypeDecimalNumberOrNil,KEY)
#define txlMeta_soks_key_date(INDEX,CONTEXT,KEY)       txlMeta_soks_key_or_relation(txlMeta_KEY,CONTEXT,TXLTypeDateOrNil,KEY)
#define txlMeta_soks_key_url(INDEX,CONTEXT,KEY)        txlMeta_soks_key_or_relation(txlMeta_KEY,CONTEXT,TXLTypeURLOrNil,KEY)

#define txlMeta_soks_string_keys(NAME,...)      metamacro_foreach_cxt(txlMeta_soks_key_string,,NAME,__VA_ARGS__)
#define txlMeta_soks_dictionary_keys(NAME,...)  metamacro_foreach_cxt(txlMeta_soks_key_dictionary,,NAME,__VA_ARGS__)
#define txlMeta_soks_array_keys(NAME,...)       metamacro_foreach_cxt(txlMeta_soks_key_array,,NAME,__VA_ARGS__)
#define txlMeta_soks_number_keys(NAME,...)      metamacro_foreach_cxt(txlMeta_soks_key_number,,NAME,__VA_ARGS__)
#define txlMeta_soks_decimal_keys(NAME,...)     metamacro_foreach_cxt(txlMeta_soks_key_decimal,,NAME,__VA_ARGS__)
#define txlMeta_soks_date_keys(NAME,...)        metamacro_foreach_cxt(txlMeta_soks_key_date,,NAME,__VA_ARGS__)
#define txlMeta_soks_url_keys(NAME,...)         metamacro_foreach_cxt(txlMeta_soks_key_url,,NAME,__VA_ARGS__)

//--relations
#define txlMeta_soks_relation_dictionary(INDEX,CONTEXT,KEY) txlMeta_soks_key_or_relation(txlMeta_RELATION,CONTEXT,TXLTypeDictionaryOrNil,KEY)

#define txlMeta_soks_dictionary_relations(NAME,...)  metamacro_foreach_cxt(txlMeta_soks_relation_dictionary,,NAME,__VA_ARGS__)

#define txlMeta_soks_relation_class(NAME,BASE_CLASS,RELATION)   \
if ([key isEqualToString:txlMeta_RELATION(NAME,RELATION)]) {    \
if (!object || ![object isKindOfClass:[BASE_CLASS class]])      \
object = nil;                                               \
self.RELATION = (BASE_CLASS *)object;                           \
return;                                                         \
}

//--header / footer
#define txlMeta_soks_header if (!TXLTypeNonEmptyStringOrNil(key)) return;
#define txlMeta_soks_footer   [super setObject:object forKeyedSubscript:key];

// KEY_PATHS_FOR_VALUES_AFFECTING_VALUE_FOR_KEY ------------------------------------------------------------------------

//--keys
#define txlMeta_kpvk_key(INDEX,NAME,KEY) \
if ([key isEqualToString:@metamacro_stringify(txlMeta_KEY_VALUE(KEY))]) {   \
NSSet *affectingKey = [NSSet setWithObject:txlMeta_KEY(NAME,KEY)];      \
keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];               \
return keyPaths;                                                            \
}

#define txlMeta_kpvk_keys(NAME,...) metamacro_foreach_cxt(txlMeta_kpvk_key,,NAME,__VA_ARGS__)

//--header / footer
#define txlMeta_kpvk_header NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
#define txlMeta_kpvk_footer return keyPaths;

// EQUALITY & UNIQUENESS -----------------------------------------------------------------------------------------------


#define txlMeta_iVarKey(KEY)  metamacro_concat(_,KEY)

#define txlMeta_isEqual_propKey(INDEX,OTHER,KEY)       \
if (! (self.KEY== OTHER.KEY || [self.KEY isEqual: OTHER.KEY])) { return NO; }

#define txlMeta_isEqual_key(INDEX,OTHER,KEY)       \
if (! (txlMeta_iVarKey(KEY) == OTHER->txlMeta_iVarKey(KEY) || \
[txlMeta_iVarKey(KEY) isEqual:OTHER->txlMeta_iVarKey(KEY)])) \
{ return NO; }

#define txlMeta_isEqual_propKeys(BASE_CLASS,...) \
if (!obj || ![obj isKindOfClass:[BASE_CLASS class]]) \
{ return NO; } \
BASE_CLASS *other = (BASE_CLASS *)obj; \
metamacro_foreach_cxt(txlMeta_isEqual_propKey,,other,__VA_ARGS__) \
return YES;

#define txlMeta_isEqual_keys(BASE_CLASS,...) \
if (!obj || ![obj isKindOfClass:[BASE_CLASS class]]) \
{ return NO; } \
BASE_CLASS *other = (BASE_CLASS *)obj; \
metamacro_foreach_cxt(txlMeta_isEqual_key,,other,__VA_ARGS__) \
return YES;

#define txlMeta_hash_propKey(INDEX,HASHVAR,KEY)   HASHVAR = TXLValueHashForHashIndex([self.KEY hash],INDEX + 1) ^ HASHVAR;

#define txlMeta_hash_propKeys(...) \
NSUInteger current = 31;  \
metamacro_foreach_cxt(txlMeta_hash_propKey,,current,__VA_ARGS__) \
return current;

#define txlMeta_hash_key(INDEX,HASHVAR,KEY)   HASHVAR = TXLValueHashForHashIndex([txlMeta_iVarKey(KEY) hash],INDEX + 1) ^ HASHVAR;

#define txlMeta_hash_keys(...) \
NSUInteger current = 31;  \
metamacro_foreach_cxt(txlMeta_hash_key,,current,__VA_ARGS__) \
return current;

// PROPERTIES ----------------------------------------------------------------------------------------------------------

#define txlMeta_prop_copyro_def(INDEX,TYPE,ARG)   @property (nonatomic,copy,readonly) TYPE * ARG;
#define txlMeta_props_copyro_def(TYPE,...)        metamacro_foreach_cxt(txlMeta_prop_copyro_def,, TYPE,__VA_ARGS__)

#define txlMeta_prop_copyrw_def(INDEX,TYPE,ARG)   @property (nonatomic,copy) TYPE * ARG;
#define txlMeta_props_copyrw_def(TYPE,...)        metamacro_foreach_cxt(txlMeta_prop_copyrw_def,, TYPE,__VA_ARGS__)

// GETTERS & SETTERS ---------------------------------------------------------------------------------------------------

#define txlMeta_set(TYPE,KEY,UPPER_KEY)               \
- (void)txlMeta_KEY_SETVALUE(UPPER_KEY):(TYPE)value {  \
metamacro_concat(_,KEY) = @(value);                    \
}

#define txlMeta_get(TYPE,OPERATION,KEY)        \
- (TYPE)txlMeta_KEY_VALUE(KEY) {               \
return [metamacro_concat(_,KEY) OPERATION];    \
}

#define txlMeta_getset_type(TYPE,OPERATION,KEY,UPPER_KEY) \
txlMeta_get(TYPE,OPERATION,KEY)                            \
txlMeta_set(TYPE,KEY,UPPER_KEY)

#define txlMeta_getset_BOOL(KEY,UPPER_KEY)        txlMeta_getset_type(BOOL,boolValue,KEY,UPPER_KEY)
#define txlMeta_getset_SHORT_INT(KEY,UPPER_KEY)   txlMeta_getset_type(int16_t,shortValue,KEY,UPPER_KEY)
#define txlMeta_getset_LONG_INT(KEY,UPPER_KEY)    txlMeta_getset_type(int64_t,longLongValue,KEY,UPPER_KEY)

#define txlMeta_secureCodingSet_allowedString      [NSSet setWithObjects:[NSString class], [NSNull class], nil]
#define txlMeta_secureCodingSet_allowedNumber      [NSSet setWithObjects:[NSNumber class], [NSNull class], nil]
#define txlMeta_secureCodingSet_allowedDecimal     [NSSet setWithObjects:[NSNumber class], [NSDecimalNumber class], [NSNull class], nil]
#define txlMeta_secureCodingSet_allowedDate        [NSSet setWithObjects:[NSDate class], [NSNull class], nil]
#define txlMeta_secureCodingSet_allowedSort        [NSSet setWithObjects:[NSSortDescriptor class], [NSString class], [NSDictionary class], [NSArray class], [NSNull class], nil]
#define txlMeta_secureCodingSet_allowedCollection  [NSSet setWithObjects:[NSString class], [NSNumber class], [NSDecimalNumber class], [NSDictionary class], [NSArray class], [NSNull class], nil]
