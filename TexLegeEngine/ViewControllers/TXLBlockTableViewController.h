//
//  TXLBlockTableViewController.h
//  TexLege
//
//  Created by Gregory Combs on 12/31/15.
//  Copyright © 2015 TexLege. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TXLBlockListViewBlock)(UITableView *tableView);

@interface TXLBlockTableViewController : UITableViewController

@property (nonatomic,copy) TXLBlockListViewBlock onViewDidLoad;

@end
