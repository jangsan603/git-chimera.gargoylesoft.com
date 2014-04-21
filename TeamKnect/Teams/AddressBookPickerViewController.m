//
//  AddressBookPickerViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/24/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "AddressBookPickerViewController.h"
#import <AddressBook/AddressBook.h>
#import "AddressBookCell.h"
#import "AddressBookRow.h"

@interface AddressBookPickerViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSMutableArray *searchData;
@property (nonatomic, unsafe_unretained) ABAddressBookRef addressBook;
@end

@implementation AddressBookPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    self.tableView.sectionIndexMinimumDisplayRowCount = 1;
//    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.searchDisplayController.active = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CFErrorRef error = NULL;
    
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusAuthorized:
            self.addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            
            [self accessGrantedForAddressBook];
            break;
        case kABAuthorizationStatusNotDetermined:
            self.addressBook = ABAddressBookCreateWithOptions(NULL, &error);

            [self requestAddressBookAccess];
            break;
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
            [BlockAlertView okWithMessage:NSLocalizedString(@"GRANT_ADDRESS_BOOK", @"Message telling them to go add permissions to the address book")];
            break;
    }
}

- (void)requestAddressBookAccess
{
    __typeof__(self) __weak weakSelf = self;
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
        if (granted)
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf accessGrantedForAddressBook];
            });
    });
}

- (void)accessGrantedForAddressBook {
    BOOL lastFirst = [[[NSUserDefaults standardUserDefaults] valueForKey:@"name_preference"] isEqualToString:@"lf"];
    
    NSMutableArray *people = [NSMutableArray new];
    
    CFArrayRef sources = ABAddressBookCopyArrayOfAllSources(self.addressBook);
    if (sources != NULL) {
        for (CFIndex i = CFArrayGetCount(sources) - 1; i >= 0; i--) {
            ABRecordRef source = (ABRecordRef) CFArrayGetValueAtIndex(sources, i);
            
            [people addObjectsFromArray:CFBridgingRelease(ABAddressBookCopyArrayOfAllPeopleInSource(self.addressBook, source))];
        }
        
        CFRelease(sources);
        
        if (people.count == 0) {
            [BlockAlertView okWithMessage:NSLocalizedString(@"NO_EMAIL", @"Message stating that nobody in their address book has an email address.")];
            return;
        }
        
        // Now that we've got a list of *sorted* people, turn them into buckets so we can do grouping.
        NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] count];
        
        NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
        for (NSInteger i = sectionTitlesCount - 1; i >= 0; i--)
            [ary addObject:[NSMutableSet new]];
        
        for (id r in people) {
            ABRecordRef record = (__bridge ABRecordRef)r;
            
            ABMultiValueRef emails = ABRecordCopyValue(record, kABPersonEmailProperty);
            if (emails == NULL)
                continue;
            
            const NSString *const first = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
            const NSString *const last = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
            const NSString *const middle = CFBridgingRelease(ABRecordCopyValue(record, kABPersonMiddleNameProperty));
            
            for (CFIndex i = ABMultiValueGetCount(emails) - 1; i >= 0; i--) {
                AddressBookRow *entry = [AddressBookRow new];
                entry.email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, i));
                
                if (lastFirst) {
                    if (middle)
                        entry.name = [NSString stringWithFormat:@"%@, %@ %@", last, first, middle];
                    else
                        entry.name = [NSString stringWithFormat:@"%@, %@", last, first];
                } else if (middle)
                    entry.name = [NSString stringWithFormat:@"%@ %@ %@", first, middle, last];
                else
                    entry.name = [NSString stringWithFormat:@"%@ %@", first, last];
                
                entry.selected = NO;
                
                const NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:entry collationStringSelector:@selector(name)];
                [ary[sectionNumber] addObject:entry];
            }
            
            CFRelease(emails);
        }
        
        const NSSortDescriptor *const byName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        const NSSortDescriptor *const byEmail = [NSSortDescriptor sortDescriptorWithKey:@"email" ascending:YES];
        
        NSMutableArray *sorted = [NSMutableArray new];
        for (NSMutableSet *set in ary)
            [sorted addObject:[set sortedArrayUsingDescriptors:@[byName, byEmail]]];
        
        self.tableData = sorted;
        [self.tableView reloadData];
        
        CFRelease(self.addressBook);
    }
    
    self.addressBook = nil;
}

- (NSArray *)selectedEmails {
    NSMutableArray *ret = [NSMutableArray array];

    for (NSArray *section in self.tableData)
        for (AddressBookRow *row in section)
            if (row.selected)
                [ret addObject:row.email];

    return ret;
}

#pragma mark - === Table View === -

- (AddressBookRow *)rowForTableView:(const UITableView *const)tableView indexPath:(const NSIndexPath *const)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return self.searchData[indexPath.row];
    else
        return self.tableData[indexPath.section][indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 1;
    else
        return [self.tableData count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *ary = [[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] mutableCopy];
    [ary insertObject:UITableViewIndexSearch atIndex:0];
    return ary;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];

    const AddressBookRow *const person = [self rowForTableView:tableView indexPath:indexPath];

    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = person.email;
    [cell setSelectionState:person.selected];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressBookRow *person = [self rowForTableView:tableView indexPath:indexPath];
    person.selected = !person.selected;

    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [self.searchData count];
    else
        return [self.tableData[section] count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index == 0) {
        [self.searchDisplayController setActive:YES animated:YES];
        return NSNotFound;
    } else
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index - 1];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *const str = [[UILocalizedIndexedCollation currentCollation] sectionTitles][section];
    
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    view.textLabel.attributedText  = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName : kTintColor}];
    view.contentView.backgroundColor = RGB_COLOR(222, 228, 235);
    
    return view;
}

#pragma mark - === Search Controller === -

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    controller.searchBar.showsCancelButton = NO;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    //  controller.searchBar.showsCancelButton = YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSMutableArray *ret = [NSMutableArray new];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(self.name CONTAINS[cd] '%@') || (self.email CONTAINS[cd] '%@')", searchString, searchString]];

    for (NSArray *section in self.tableData)
        [ret addObjectsFromArray:[section filteredArrayUsingPredicate:predicate]];

    self.searchData = ret;

    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    [controller.searchResultsTableView registerClass:[AddressBookCell class] forCellReuseIdentifier:@"normal"];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchDisplayController setActive:NO animated:YES];
}

@end
