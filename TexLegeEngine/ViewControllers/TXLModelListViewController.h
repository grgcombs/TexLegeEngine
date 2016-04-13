//
//  TXLModelListViewController.h
//  TexLege
//
//  Created by Gregory Combs on 3/30/15
//  Copyright (c) 2014 TexLege. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXLDataLoader.h"

@class RACSignal;
@class TXLModel;
@class TXLBlockTableViewController;
@class TXLBlockListDataSource;

@interface TXLModelListViewController : UIViewController <UITableViewDataSource,
                                                 UITableViewDelegate,
                                                 UISearchBarDelegate,
                                                 UISearchControllerDelegate,
                                                 UISearchResultsUpdating,
                                                 TXLDatabaseObserver>

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) RACSignal *loadObjectsSignal;
@property (nonatomic,strong,readonly) TXLBlockTableViewController *resultsController;
@property (nonatomic,strong,readonly) TXLBlockListDataSource *resultsDataSource;
@property (nonatomic,strong,readonly) UISearchController *searchController;

+ (NSString *)viewKey;
+ (NSString  *)searchKey;
- (TXLModel *)objectAtIndexPath:(NSIndexPath *)indexPath;
- (void)didConfigureViews;
- (UITableViewCell *)tableView:(UITableView *)tableView searchCellForResult:(TXLModel *)result atIndexPath:(NSIndexPath *)indexPath;

@end
