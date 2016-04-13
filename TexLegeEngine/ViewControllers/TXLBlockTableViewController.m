//
//  TXLBlockTableViewController.m
//  TexLege
//
//  Created by Gregory Combs on 12/31/15.
//  Copyright © 2015 TexLege. All rights reserved.
//

#import "TXLBlockTableViewController.h"

@interface TXLBlockTableViewController ()

@end

@implementation TXLBlockTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.onViewDidLoad)
        self.onViewDidLoad(self.tableView);
}

- (void)setOnViewDidLoad:(TXLBlockListViewBlock)onViewDidLoad
{
    _onViewDidLoad = [onViewDidLoad copy];

    if (!self.isViewLoaded || !onViewDidLoad)
        return;

    onViewDidLoad(self.tableView);
}

@end
