//
//  GSCalendarListViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/27/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSCalendarListViewController.h"
#import <EventKit/EventKit.h>
#import "AppDelegate.h"
#import "Team.h"

@interface GSCalendarListViewController ()
@property (nonatomic, copy) NSArray *tableData;
@property (nonatomic, copy) NSArray *teams;
@end

@implementation GSCalendarListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSFetchRequest *const request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    request.predicate = [NSPredicate predicateWithFormat:@"calendarIdentifier != nil"];
    request.propertiesToFetch = @[@"calendarIdentifier"];

    NSManagedObjectContext *moc = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
    const NSArray *const teams = [moc executeFetchRequest:request error:NULL];
    if (teams.count == 0)
        return;

    NSMutableArray *const calendars = [NSMutableArray new];
    NSMutableArray *ary = [NSMutableArray new];
    
    for (const Team *const team in teams) {
        const EKCalendar *const cal = [[CalendarEventStore sharedInstance] calendarWithIdentifier:team.calendarIdentifier];
        if (cal) {
            [ary addObject:team];
            [calendars addObject:cal];
        }
    }

    self.teams = ary;
    self.tableData = calendars;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];

    const EKCalendar *const calendar = self.tableData[indexPath.row];
    cell.textLabel.text = calendar.title;
    cell.imageView.image = [[UIImage imageNamed:@"dot_calendar_tintable"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.tintColor = [UIColor colorWithCGColor:calendar.CGColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.onSelect)
        self.onSelect(self.teams[indexPath.row], self.tableData[indexPath.row]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

@end
