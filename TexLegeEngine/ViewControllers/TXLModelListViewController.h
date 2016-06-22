//
//  TXLModelListViewController.h
//  TexLege
//
//  Created by Gregory Combs on 3/30/15
//  Copyright (c) 2014 TexLege. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXLDataLoader.h"
#import "TXLModelReceiverProtocol.h"
#import "TXLBlockListDataSource.h"

@class RACSignal;
@class TXLModel;
@class TXLBlockTableViewController;

typedef UITableViewCell<TXLModelReceiverProtocol>*(^TXLModelListTableCellBlock)(UITableView *tableView, NSIndexPath *indexPath);

@interface TXLModelListViewController : UIViewController <UITableViewDataSource,
                                                 UITableViewDelegate,
                                                 UISearchBarDelegate,
                                                 UISearchControllerDelegate,
                                                 UISearchResultsUpdating,
                                                 TXLDatabaseObserver>

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) RACSignal *loadObjectsSignal;
@property (nonatomic,copy) TXLBlockListIndexPathBlock onDidSelectRow;
@property (nonatomic,copy) TXLModelListTableCellBlock onConfigureCell;

// For search results
@property (nonatomic,strong,readonly) TXLBlockTableViewController *resultsController;
@property (nonatomic,strong,readonly) TXLBlockListDataSource *resultsDataSource;
@property (nonatomic,strong,readonly) UISearchController *searchController;

+ (NSString *)viewKey;
+ (NSString  *)searchKey;
+ (NSString *)modelCellReuseIdentifier;
+ (NSString *)searchCellReuseIdentifier; // defaults to the value of modelCellReuseIdentifier

- (TXLModel *)objectAtIndexPath:(NSIndexPath *)indexPath;
- (void)didConfigureViews;

- (UITableViewCell *)tableView:(UITableView *)tableView searchCellForResult:(TXLModel *)result atIndexPath:(NSIndexPath *)indexPath;

/**
 *  @author Greg Combs, Jun 21, 2016
 *
 *  Returns the model object (whether from the search results or from loaded data) at the given index path.
 *
 *  @param tableView The applicable table view (either the search results table view or the primary model list table view).
 *  @param indexPath The index path of the desired model object.
 *
 *  @return The requested model object, or nil if not found.
 */
- (TXLModel *)tableView:(UITableView *)tableView objectAtIndexPath:(NSIndexPath *)indexPath;

@end
