//
//  TXLModel.h
//  TexLege
//
//  Created by Gregory Combs on 4/6/15.
//  Copyright (c) 2015 TexLege. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "TXLMetaMacros.h"

@interface TXLModel : MTLModel<NSSecureCoding,MTLJSONSerializing>

- (id)objectForKeyedSubscript:(NSString *)key;

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;

+ (BOOL)supportsSecureCoding;

/**
 *  @author Greg Combs, Jun 18, 2015
 *
 *  Merge values from another model into the receiver. Optionally provide an array of property keys to exclude
 *  from the merge.  (Useful for not overwriting newer IDs with older ones).
 *
 *  @param model        The model to merge into the receiver.
 *  @param excludedKeys An array of property keys to exclude from merge.
 */
- (void)mergeValuesForKeysFromModel:(MTLModel *)model excludingKeys:(NSArray *)excludedKeys;

/**
 *  A short description of the model.  The default implementation just returns the standard 'description'.
 *
 *  @return A shorter description of the model (if implemented), otherwise the usual 'description'.
 */
- (NSString *)shortDescription;

@end

@protocol TXLOldModelIdentifiers <NSObject>

txlMeta_props_copyro_def(NSArray,oldIds);

@end