//
//  TXLLegislatorListViewController.m
//  TexLege
//
//  Created by Gregory Combs on 12/31/15.
//  Copyright © 2015 TexLege. All rights reserved.
//

#import "TXLLegislatorListViewController.h"
#import "TXLLegislator.h"
#import "TXLBlockListDataSource.h"
#import "TXLBlockTableViewController.h"

static NSString * const kLegislatorCellID = @"TXLLegislatorCell";

@interface TXLLegislatorListViewController ()
@property (nonatomic,strong) NSPersonNameComponentsFormatter *nameFormatter;
@end

@implementation TXLLegislatorListViewController

+ (NSString *)viewKey
{
    return txlMeta_KEY(TXLDataLoader, legislatorListView);
}

+ (NSString *)searchKey
{
    return txlMeta_KEY(TXLDataLoader, legislatorListSearch);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _nameFormatter = [[NSPersonNameComponentsFormatter alloc] init];
    _nameFormatter.style = NSPersonNameComponentsFormatterStyleMedium;
}

- (RACSignal *)loadObjectsSignal
{
    RACSignal *signal = [super loadObjectsSignal];
    if (!signal)
    {
        signal = [[TXLDataLoader currentLoader] loadLegislators];
        self.loadObjectsSignal = signal;
    }
    return signal;
}

- (void)didConfigureViews
{
    [self.tableView registerNib:[UINib nibWithNibName:kLegislatorCellID bundle:nil] forCellReuseIdentifier:kLegislatorCellID];
    self.resultsController.onViewDidLoad = ^(UITableView *tableView) {
        [tableView registerNib:[UINib nibWithNibName:kLegislatorCellID bundle:nil] forCellReuseIdentifier:kLegislatorCellID];
    };
    
    self.title = NSLocalizedString(@"Legislators", @"Title for the legislator list");

    //self.searchController.searchBar.scopeButtonTitles = @[@"All",@"Senate",@"House"];
    //self.searchController.searchBar.showsScopeBar = YES;

    [super didConfigureViews];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLegislatorCellID forIndexPath:indexPath];
    cell.textLabel.attributedText = nil;
    cell.detailTextLabel.text = nil;

    TXLLegislator *legislator = TXLValueIfClass(TXLLegislator, [self objectAtIndexPath:indexPath]);

    if (!legislator)
        return cell;

    cell.textLabel.attributedText = [self.nameFormatter annotatedStringFromPersonNameComponents:legislator.nameComponents];
    cell.detailTextLabel.text = legislator.party;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView searchCellForResult:(TXLModel *)result atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLegislatorCellID forIndexPath:indexPath];
    cell.textLabel.attributedText = nil;
    cell.detailTextLabel.text = nil;

    TXLLegislator *legislator = TXLValueIfClass(TXLLegislator, result);
    if (!result)
        return cell;

    cell.textLabel.attributedText = [self.nameFormatter annotatedStringFromPersonNameComponents:legislator.nameComponents];
    cell.detailTextLabel.text = legislator.party;

    return cell;
}


@end
