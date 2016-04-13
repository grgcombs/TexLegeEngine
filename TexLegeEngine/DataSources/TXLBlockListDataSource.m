//
//  TXLBlockListDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 12/30/15.
//  Copyright © 2015 TexLege. All rights reserved.
//

#import "TXLBlockListDataSource.h"

@interface TXLBlockListDataSource ()
@property (nonatomic,assign,readonly) TXLBlockListHelperType helperType;
@end

@implementation TXLBlockListDataSource

- (instancetype)initWithHelperType:(TXLBlockListHelperType)helperType
{
    self = [super init];
    if (self)
    {
        _helperType = helperType;
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithHelperType:TXLBlockListHelperDelegateAndDataSourceType];
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(self.helperType & TXLBlockListHelperDataSourceType);
    NSParameterAssert(self.onConfigureCell != NULL);
    return self.onConfigureCell(tableView, indexPath);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSParameterAssert(self.helperType & TXLBlockListHelperDataSourceType);
    if (!self.onNumberOfSections)
        return 1;
    return self.onNumberOfSections(tableView);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(self.helperType & TXLBlockListHelperDataSourceType);
    NSParameterAssert(self.onNumberOfSections != NULL);
    return self.onNumberOfRows(tableView,section);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSParameterAssert(self.helperType & TXLBlockListHelperDataSourceType);
    if (!self.onSectionTitle)
        return nil;
    return self.onSectionTitle(tableView,section);
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSParameterAssert(self.helperType & TXLBlockListHelperDataSourceType);
    if (!self.onSectionTitleIndex)
        return 0;
    return self.onSectionTitleIndex(tableView,title,index);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(self.helperType & TXLBlockListHelperDelegateType);
    if (!self.onDidSelectRow)
        return;
    self.onDidSelectRow(tableView,indexPath);
}

@end
