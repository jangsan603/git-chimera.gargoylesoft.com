//
//  GSEventEditorRepeatEndViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSEventEditorRepeatEndViewController.h"

@interface GSEventEditorRepeatEndViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *picker;
@property (nonatomic, assign) NSInteger checkedRow;
@end

@implementation GSEventEditorRepeatEndViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.bounces = NO;
    
    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    
    self.picker.datePickerMode = UIDatePickerModeDate;
    
    if (self.date) {
        self.checkedRow = 1;
        self.picker.date = self.date;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.checkedRow == 0 ? 2 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // They're static cells, so load them from the storyboard directly by calling parent.
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = self.checkedRow == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    if (indexPath.row == 0)
        cell.textLabel.text = [LocalizedStrings repeatEndNever];
    else if (indexPath.row == 1)
        cell.textLabel.text = NSLocalizedString(@"CALENDAR_REPEAT_END_ON_DATE", @"Calendar recurrence end will be on a specific date.");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2)
        return;
    
    if ((self.checkedRow = indexPath.row) == 0 && self.onSelection)
        self.onSelection(nil);
    
    // This causes the date to show/hide appropriately.
    [tableView reloadData];
}

- (IBAction)datePickerValueChanged:(UIDatePicker *)sender {
    if (self.onSelection)
        self.onSelection(sender.date);
}

@end
