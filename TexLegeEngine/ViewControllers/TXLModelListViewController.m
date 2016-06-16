//
//  TXLModelListViewController.m
//  TexLege
//
//  Created by Gregory Combs on 3/30/15
//  Copyright (c) 2014 TexLege. All rights reserved.
//

#import "TXLModelListViewController.h"
#import "TXLModel.h"
#import "TXLBlockListDataSource.h"
#import "TXLBlockTableViewController.h"
#import "TexLege-Environment.h"
#import "TXLYapDatabase.h"
#import "TexLegeEngine.h"

@interface TXLModelListViewController ()
@property (nonatomic,strong) YapDatabaseViewMappings *mappings;
@property (nonatomic,copy) NSArray *sectionIndexKeys;
@property (nonatomic,assign) BOOL searchWasActive;
@property (nonatomic,assign) BOOL searchFieldWasFirstResponder;
@property (nonatomic,strong) TXLBlockTableViewController *resultsController;
@property (nonatomic,strong) TXLBlockListDataSource *resultsDataSource;
@property (nonatomic,strong) UISearchController *searchController;
@property (nonatomic,weak) IBOutlet UIView *searchBarContainer;
@property (nonatomic,strong) NSLayoutConstraint *searchBarOffset;
@property (nonatomic,strong) NSArray *searchBarConstraints;
@property (nonatomic,copy) NSArray *searchResults;
@end

txlMeta_keys_def(TXLModelList,stateControllerTitle,stateSearchActive,stateSearchText,stateSearchFirstResponder);
txlMeta_keys_impl(TXLModelList,stateControllerTitle,stateSearchActive,stateSearchText,stateSearchFirstResponder);

@implementation TXLModelListViewController

+ (NSString *)viewKey
{
    NSAssert(NO, @"Subclasses must implement their own viewKey");
    return nil;
}

+ (NSString *)searchKey
{
    NSAssert(NO, @"Subclasses must implement their own searchKey");
    return nil;
}

+ (BOOL)isSearchableList
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.cellLayoutMarginsFollowReadableWidth = YES;
    self.tableView.sectionIndexMinimumDisplayRowCount = 15;

    NSParameterAssert(self.loadObjectsSignal != NULL);

    @weakify(self);

    TXLBlockListDataSource *resultsDataSource = [[TXLBlockListDataSource alloc] initWithHelperType:TXLBlockListHelperDataSourceType];
    resultsDataSource.onNumberOfSections = ^NSInteger(UITableView *tableView){
        return 1;
    };
    resultsDataSource.onNumberOfRows = ^NSInteger(UITableView *tableView, NSInteger section){
        @strongify(self);
        return (NSInteger)self.searchResults.count;
    };
    resultsDataSource.onConfigureCell = ^UITableViewCell*(UITableView *tableView, NSIndexPath *indexPath){
        @strongify(self);
        id result = self.searchResults[(NSUInteger)indexPath.row];
        return [self tableView:tableView searchCellForResult:result atIndexPath:indexPath];
    };

    TXLBlockTableViewController *resultsController = [[TXLBlockTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:resultsController];

    _resultsDataSource = resultsDataSource;
    _resultsController = resultsController;
    _searchController = searchController;

    resultsController.tableView.dataSource = resultsDataSource;
    resultsController.tableView.delegate = self;
    searchController.searchResultsUpdater = self;
    searchController.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO;

    UISearchBar *searchBar = searchController.searchBar;
    searchBar.delegate = self;

    self.definesPresentationContext = YES;

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        if (!self)
            return [RACSignal empty];
        return self.loadObjectsSignal;
    }];
    [self.tableView addSubview:refresh];

    [self didConfigureViews];

    [self.loadObjectsSignal subscribeNext:^(NSDictionary *objects) {
        //DDLogInfo(@"Did next");
    } error:^(NSError *error) {
        DDLogError(@"Error: %@", error);
    } completed:^{
        @strongify(self);
        if (!self)
            return;

        [self didCompleteLoadObjects];
    }];
}

- (void)dealloc
{
    TXLDataLoader *loader = [[TexLegeEngine instance] dataLoader];
    [loader removeDataModificationObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self restoreSearchState];
}

- (void)didConfigureViews
{
    UITableView *tableView = self.tableView;
    UISearchBar *searchBar = self.searchController.searchBar;
    UIView *searchContainer = self.searchBarContainer;

    CGSize searchSize = searchBar.intrinsicContentSize;
    searchSize.width = CGRectGetWidth(tableView.bounds);
    CGRect containerRect = (CGRect){CGPointZero,searchSize};
    searchContainer.frame = containerRect;
    searchBar.frame = containerRect;
    [searchContainer addSubview:searchBar];

    [self adjustSearchBarOffset];
    [self transferSearchBarLayout:searchBar toSearchController:NO];

    tableView.contentOffset = CGPointMake(0, searchSize.height);
}

- (void)didCompleteLoadObjects
{
    TXLDataLoader *loader = [[TexLegeEngine instance] dataLoader];
    YapDatabaseConnection *uiConnection = loader.uiConnection;

    [uiConnection beginLongLivedReadTransaction];

    NSMutableArray *sectionNumbers = [@[] mutableCopy];

    NSArray *indexTitles = [UILocalizedIndexedCollation currentCollation].sectionIndexTitles;
    UInt32 sectionCount = (UInt32)indexTitles.count;

    if ([[self class] isSearchableList])
    {
        // for search icon, we add an empty section
        sectionCount++;
    }

    for (UInt32 sectionNumber = 0; sectionNumber < sectionCount; sectionNumber++)
    {
        [sectionNumbers addObject:@(sectionNumber).stringValue];
    }
    self.sectionIndexKeys = sectionNumbers;

    NSString *viewKey = [self.class viewKey];
    self.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:sectionNumbers view:viewKey];

    @weakify(self);

    [uiConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        @strongify(self);
        // One-time initialization
        [self.mappings updateWithTransaction:transaction];
    }];

    [loader addDataModificationObserver:self];
}

- (void)databaseModified:(NSNotification *)notification
{
    if (!self.isViewLoaded)
        return;

    NSString *viewKey = [self.class viewKey];
    UITableView *tableView = self.tableView;

    YapDatabaseConnection *connection = [[TexLegeEngine instance] dataLoader].uiConnection;

    NSArray *notifications = [connection beginLongLivedReadTransaction];
    if (!notifications.count)
        return;

    // Grab info about current selection
    NSString *selectedGroup = nil;
    __block NSString *selectedCollection = nil;
    NSUInteger selectedRow = 0;
    __block NSString *selectedObjectId = nil;

    NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
    if (selectedIndexPath)
    {
        selectedGroup = [self.mappings groupForSection:(NSUInteger)selectedIndexPath.section];
        selectedRow = (NSUInteger)selectedIndexPath.row;
        [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            [[transaction ext:viewKey] getKey:&selectedObjectId
                                   collection:&selectedCollection
                                      atIndex:selectedRow
                                      inGroup:selectedGroup];
        }];
    }

    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    [[connection ext:viewKey] getSectionChanges:&sectionChanges
                                     rowChanges:&rowChanges
                               forNotifications:notifications
                                   withMappings:self.mappings];

    if (!sectionChanges.count && !rowChanges.count)
        return;

    NSInteger sectionCount = tableView.numberOfSections;

    [tableView beginUpdates];

    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
    {
        switch (sectionChange.type)
        {
            case YapDatabaseViewChangeDelete:
            {
                NSAssert((NSUInteger)sectionCount > sectionChange.index, @"Section index out of bounds");
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }

            case YapDatabaseViewChangeInsert:
            {
                [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }

            case YapDatabaseViewChangeMove:
            case YapDatabaseViewChangeUpdate:
            {
                NSAssert((NSUInteger)sectionCount > sectionChange.index, @"Section index out of bounds");
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                         withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }

    NSMutableArray *toInsert = [@[] mutableCopy];
    NSMutableArray *toUpdate = [@[] mutableCopy];
    NSMutableArray *toDelete = [@[] mutableCopy];

    NSMutableDictionary *sectionUpdates = [@{} mutableCopy];
    NSMutableDictionary *sectionDeletions = [@{} mutableCopy];
    for (NSString *sectionKey in self.sectionIndexKeys)
    {
        sectionUpdates[sectionKey] = [@[] mutableCopy];
        sectionDeletions[sectionKey] = [@[] mutableCopy];
    }

    for (YapDatabaseViewRowChange *rowChange in rowChanges)
    {
        NSIndexPath *changedPath = rowChange.indexPath;
        NSIndexPath *newPath = rowChange.newIndexPath;

        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete:
                [toDelete addObject:changedPath];
                break;

            case YapDatabaseViewChangeInsert:
                [toInsert addObject:newPath];
                break;

            case YapDatabaseViewChangeMove:
            {
                // we defer until we can more efficiently ask the tableView for the current number of rows
                NSString *sectionKey = @(changedPath.section).stringValue;
                [sectionDeletions[sectionKey] addObject:changedPath];
                [toInsert addObject:newPath];
                break;
            }

            case YapDatabaseViewChangeUpdate:
            {
                // we defer until we can more efficiently ask the tableView for the current number of rows
                NSString *sectionKey = @(changedPath.section).stringValue;
                [sectionUpdates[sectionKey] addObject:changedPath];
                break;
            }
        }
    }

    [sectionDeletions enumerateKeysAndObjectsUsingBlock:^(NSString *sectionIndexKey, NSArray *rowIndices, BOOL *sectionStop) {
        if (!rowIndices.count)
            return;
        NSInteger section = sectionIndexKey.integerValue;
        NSInteger rowCount = 0;
        if (sectionCount > section)
            rowCount = [tableView numberOfRowsInSection:section];
        if (rowCount == 0)
            return; // nothing to do, there isn't any existing row to delete
        [rowIndices enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *rowStop) {
            if (rowCount > indexPath.row)
                [toDelete addObject:indexPath];
        }];
    }];

    [sectionUpdates enumerateKeysAndObjectsUsingBlock:^(NSString *sectionIndexKey, NSArray *rowIndices, BOOL *sectionStop) {
        if (!rowIndices.count)
            return;
        NSInteger section = sectionIndexKey.integerValue;
        NSInteger rowCount = 0;
        if (sectionCount > section)
            rowCount = [tableView numberOfRowsInSection:section];

        if (rowCount == 0)
        {
            [toInsert addObjectsFromArray:rowIndices]; // tableView has no record of any rows for this section, insert them.
            return;
        }

        [rowIndices enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *rowStop) {
            if (rowCount > indexPath.row)
                [toUpdate addObject:indexPath];
            else
                [toInsert addObject:indexPath];
        }];
    }];

    if (toDelete.count)
        [tableView deleteRowsAtIndexPaths:toDelete withRowAnimation:UITableViewRowAnimationAutomatic];

    if (toUpdate.count)
        [tableView reloadRowsAtIndexPaths:toUpdate withRowAnimation:UITableViewRowAnimationNone];

    if (toInsert.count)
        [tableView insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [tableView endUpdates];

    [tableView reloadSectionIndexTitles];

    [self adjustSearchBarOffset];

    // Try to reselect whatever was selected before
    __block NSIndexPath *indexPath = nil;
    if (selectedIndexPath)
    {
        @weakify(self);
        [connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            @strongify(self);
            indexPath = [[transaction ext:viewKey] indexPathForKey:selectedObjectId
                                                      inCollection:selectedCollection
                                                      withMappings:self.mappings];
        }];
    }

    // Otherwise select the nearest row to whatever was selected before

    if (!indexPath && selectedGroup)
    {
        indexPath = [self.mappings nearestIndexPathForRow:selectedRow inGroup:selectedGroup];
    }

    if (indexPath)
    {
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (NSInteger)[[UILocalizedIndexedCollation currentCollation] sectionTitles].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[self.mappings numberOfItemsInGroup:@(section).stringValue];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[UILocalizedIndexedCollation currentCollation] sectionTitles][(NSUInteger)section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [@[UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    BOOL isSearchable = [[self class] isSearchableList];
    if (isSearchable) // search icon
    {
        if (index == 0)
        {
            // User tapped the search icon, scroll the table all the way up to expose the hidden search bar
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            return -1;
        }
        index--; // offset index to adjust for the search icon
    }
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (TXLModel *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *viewKey = [self.class viewKey];

    __block TXLModel *object = nil;
    @weakify(self);
    [[[TexLegeEngine instance] dataLoader].uiConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        @strongify(self);
        if (!self)
            return;
        object = [[transaction ext:viewKey] objectAtIndexPath:indexPath withMappings:self.mappings];
    }];
    return TXLValueIfClass(TXLModel, object);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Subclasses must implement their own cellForRowAtIndexPath:");
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TXLModel *selectedObject = (tableView == self.tableView) ? [self objectAtIndexPath:indexPath] : self.searchResults[(NSUInteger)indexPath.row];

    //TXLModelDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TXLModelDetailViewController"];
    //detailViewController.modelObject = selectedObject;

    //[self.navigationController pushViewController:detailViewController animated:YES];

    // note: should not be necessary but current iOS 8.0 bug (seed 4) requires it
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Search Results

- (UITableViewCell *)tableView:(UITableView *)tableView searchCellForResult:(id)result atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Subclasses must implement their own searchCellForResult:");
    return nil;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    if (searchText)
        searchText = [[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByAppendingString:@"*"];
    else
        searchText = @"*";

    NSString *searchKey = [[self class] searchKey];

    @weakify(self);

    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:100];
    [[[TexLegeEngine instance] dataLoader].uiConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        @strongify(self);
        if (!self)
            return;

        [[transaction ext:searchKey] enumerateKeysAndObjectsMatching:searchText usingBlock:^(NSString *collection, NSString *key, TXLModel *result, BOOL *stop) {
            if (!TXLValueIfClass(TXLModel, result))
                return;
            [results addObject:result];
        }];

        self.searchResults = [results copy];
        [self.resultsController.tableView reloadData];
    }];
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
    [self transferSearchBarLayout:searchController.searchBar toSearchController:YES];
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    [self adjustSearchBarOffset];
    [self transferSearchBarLayout:searchController.searchBar toSearchController:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searchController.active = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchResults = nil;
}

- (void)adjustSearchBarOffset
{
    UITableView *tableView = self.tableView;

    if (!self.searchBarOffset)
    {
        UISearchBar *searchBar = self.searchController.searchBar;
        UIView *searchContainer = self.searchBarContainer;
        _searchBarOffset = [NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:searchContainer attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:searchContainer attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:searchContainer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:searchContainer attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        _searchBarConstraints = @[top,bottom,leading,_searchBarOffset];
        //[NSLayoutConstraint activateConstraints:_searchBarConstraints];
        //[searchContainer setNeedsUpdateConstraints];
    }

    if (self.mappings.numberOfItemsInAllGroups < (NSUInteger)tableView.sectionIndexMinimumDisplayRowCount)
        self.searchBarOffset.constant = 0.0;
    else
        self.searchBarOffset.constant = -15.0;

    //[searchBar setNeedsLayout];
}

- (void)transferSearchBarLayout:(UISearchBar *)searchBar toSearchController:(BOOL)toSearchController
{
    if (!self.searchBarConstraints)
        return;

    if (toSearchController)
    {
        [NSLayoutConstraint deactivateConstraints:self.searchBarConstraints];
        searchBar.translatesAutoresizingMaskIntoConstraints = YES;
    }
    else
    {
        searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:self.searchBarConstraints];
    }
}

#pragma mark - UIStateRestoration

- (void)restoreSearchState
{
    if (!self.searchWasActive)
        return;

    UISearchController *searchController = self.searchController;
    searchController.active = self.searchWasActive;
    _searchWasActive = NO;

    if (self.searchFieldWasFirstResponder)
    {
        [searchController.searchBar becomeFirstResponder];
        _searchFieldWasFirstResponder = NO;
    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeObject:self.title forKey:txlMeta_KEY(TXLModelList, stateControllerTitle)];

    UISearchController *searchController = self.searchController;
    BOOL searchIsActive = searchController.isActive;
    [coder encodeBool:searchIsActive forKey:txlMeta_KEY(TXLModelList, stateSearchActive)];
    UISearchBar *searchBar = searchController.searchBar;
    if (searchIsActive)
        [coder encodeBool:[searchBar isFirstResponder] forKey:txlMeta_KEY(TXLModelList, stateSearchFirstResponder)];
    [coder encodeObject:searchBar.text forKey:txlMeta_KEY(TXLModelList, stateSearchText)];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];

    self.title = [coder decodeObjectForKey:txlMeta_KEY(TXLModelList, stateControllerTitle)];
    _searchWasActive = [coder decodeBoolForKey:txlMeta_KEY(TXLModelList, stateSearchActive)];
    _searchFieldWasFirstResponder = [coder decodeBoolForKey:txlMeta_KEY(TXLModelList, stateSearchFirstResponder)];
    self.searchController.searchBar.text = [coder decodeObjectForKey:txlMeta_KEY(TXLModelList, stateSearchText)];
}

@end
