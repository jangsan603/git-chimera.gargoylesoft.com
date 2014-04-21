//
//  SettingsNotificationTableViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/12/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsNotificationTableViewController.h"
#import "SettingsNotificationTableViewCell.h"

@interface SettingsNotificationTableViewController ()
@property (nonatomic, copy) NSArray *tableData;
@end

// TODO: Has to default to 1 when app first loads.

@implementation SettingsNotificationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableData = @[
                       NSLocalizedString(@"SETTINGS_NOTIFICATION_EVENTS", @"Get notified about calendar events"),
                       NSLocalizedString(@"SETTINGS_NOTIFICATION_TASKS", @"Get notified about tasks"),
                       NSLocalizedString(@"SETTINGS_NOTIFICATION_GROUP_CHAT", @"Get notified about group chat"),
                       ];
}

#pragma mark - === Table View === -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
    
    NSString *key;
    
    switch (indexPath.row) {
        case 0:
            key = @"notifyEvent";
            break;
            
        case 1:
            key = @"notifyTask";
            break;
            
        case 2:
            key = @"notifyChat";
            break;
            
        default:
            abort();
    }

    cell.onOff.on = [[[NSUserDefaults standardUserDefaults] valueForKey:key] boolValue];
    cell.title.text = self.tableData[indexPath.row];

    cell.onValueChanged = ^(BOOL isOn) {
        [[NSUserDefaults standardUserDefaults] setValue:@(isOn) forKey:key];
    };
    
    return cell;
}

@end
