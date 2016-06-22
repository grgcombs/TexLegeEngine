//
//  TXLBlockListDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 12/30/15.
//  Copyright © 2015 TexLege. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TXLBlockListDataSource;

typedef void(^TXLBlockListIndexPathBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef UITableViewCell*(^TXLBlockListTableCellBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef NSInteger(^TXLBlockListIntegerBlock)(UITableView *tableView);
typedef NSInteger(^TXLBlockListRowCountBlock)(UITableView *tableView, NSInteger section);
typedef NSString*(^TXLBlockListSectionStringBlock)(UITableView *tableView, NSInteger section);
typedef NSInteger(^TXLBlockListSectionTitleIndexBlock)(UITableView *tableView, NSString *title, NSInteger section);

typedef NS_OPTIONS(NSUInteger, TXLBlockListHelperType) {
    TXLBlockListHelperDelegateType = 1 << 0,
    TXLBlockListHelperDataSourceType = 1 << 1,
    TXLBlockListHelperDelegateAndDataSourceType = (1 << 0) | (1 << 1),
};

@interface TXLBlockListDataSource : NSObject <UITableViewDataSource,UITableViewDelegate>

- (instancetype)initWithHelperType:(TXLBlockListHelperType)helperType NS_DESIGNATED_INITIALIZER;
@property (nonatomic,copy) TXLBlockListTableCellBlock onConfigureCell;
@property (nonatomic,copy) TXLBlockListIntegerBlock onNumberOfSections;
@property (nonatomic,copy) TXLBlockListRowCountBlock onNumberOfRows;
@property (nonatomic,copy) TXLBlockListIndexPathBlock onDidSelectRow;
@property (nonatomic,copy) TXLBlockListSectionStringBlock onSectionTitle;
@property (nonatomic,copy) TXLBlockListSectionTitleIndexBlock onSectionTitleIndex;

@end
