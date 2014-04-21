//
//  GSEventEditorRepeatViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSEventEditorRepeatViewController.h"

@interface GSEventEditorRepeatViewController ()
@property (nonatomic, copy) NSArray *tableData;
@end

@implementation GSEventEditorRepeatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableData = @[
                       [LocalizedStrings repeatNone],
                       [LocalizedStrings repeatDaily],
                       [LocalizedStrings repeatWeekly],
                       [LocalizedStrings repeatEveryTwoWeeks],
                       [LocalizedStrings repeatMonthly],
                       [LocalizedStrings repeatYearly]
                       ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
    
    cell.textLabel.text = self.tableData[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.recurring = YES;
    self.interval = 1;
    
    switch (indexPath.row) {
        case 0:
            self.recurring = NO;
            self.text = [LocalizedStrings repeatNone];
            break;
        case 1:
            self.frequency = EKRecurrenceFrequencyDaily;
            self.text = [LocalizedStrings repeatDaily];
            break;
        case 2:
            self.frequency = EKRecurrenceFrequencyWeekly;
            self.text = [LocalizedStrings repeatWeekly];
            break;
        case 3:
            self.frequency = EKRecurrenceFrequencyWeekly;
            self.text = [LocalizedStrings repeatEveryTwoWeeks];
            self.interval = 2;
            break;
        case 4:
            self.frequency = EKRecurrenceFrequencyMonthly;
            self.text = [LocalizedStrings repeatMonthly];
            break;
        case 5:
            self.frequency = EKRecurrenceFrequencyYearly;
            self.text = [LocalizedStrings repeatYearly];
            break;
    }

    [self performSegueWithIdentifier:@"calendarRecurrenceTypeWasSelected" sender:self];
}

@end
