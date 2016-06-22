//
//  TXLModelReceiverProtocol.h
//  TexLegeEngine
//
//  Created by Gregory Combs on 6/21/16.
//  Copyright © 2016 TexLege. All rights reserved.
//

#import "TXLModel.h"

@protocol TXLModelReceiverProtocol <NSObject>

/**
 *  @author Greg Combs, Jun 21, 2016
 *
 *  Use the modelObject setter to configure conforming classes, like a model-savvy table view cell.
 */
@property (nonatomic,strong) TXLModel *modelObject;

@end
