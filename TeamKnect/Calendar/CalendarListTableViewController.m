//
//  CalendarListTableViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/13/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarListTableViewController.h"
#import "GSEventEditorViewController.h"
#import "CalendarListCell.h"
#import "Team+Category.h"
#import "AppDelegate.h"

@interface CalendarListTableViewController ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *tableData;
@end

@implementation CalendarListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalendar:) name:NSCurrentLocaleDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalendar:) name:EKEventStoreChangedNotification object:nil];
    
    __typeof__(self) __weak weakSelf = self;

    [[NSNotificationCenter defaultCenter] addObserverForName:kJumpToSpecificDayNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        weakSelf.dayBeingDisplayed = note.userInfo[kJumpToSpecificDayValue];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    self.dateFormatter = nil;
    
    [super didReceiveMemoryWarning];
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter)
        return _dateFormatter;

    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.dateStyle = NSDateFormatterNoStyle;
    _dateFormatter.timeStyle = NSDateFormatterShortStyle;

    return _dateFormatter;
}

#pragma mark - === Calendar === -

- (void)reloadCalendar:(NSNotification *)note {
    self.dayBeingDisplayed = self.dayBeingDisplayed;
}

- (void)loadAllTeamCalendars {
    NSArray *calendars = [[CalendarEventStore sharedInstance] allocTeamCalendarsInManagedObjectContext:self.managedObjectContext];
    if (calendars.count == 0)
        return;
    
    [self loadCalendars:calendars];
}

- (void)loadCalendarForTeam {
    EKCalendar *calendar = [[CalendarEventStore sharedInstance] calendarWithIdentifier:self.team.calendarIdentifier];

    if (!calendar) {
        [BlockAlertView okWithMessage:@"Catastrophic failure.  Unable to find that team's calendar identifier"];

        return;
    }

    [self loadCalendars:@[calendar]];
}

- (void)loadCalendars:(NSArray *)calendars {
    const NSUInteger wanted = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *const components = [self.calendar components:wanted fromDate:self.dayBeingDisplayed];

    NSDate *const startOfDay = [self.calendar dateFromComponents:components];

    components.hour = 23;
    components.minute = 59;
    components.second = 59;

    NSDate *const endOfDay = [self.calendar dateFromComponents:components];

    NSPredicate *const predicate = [[CalendarEventStore sharedInstance] predicateForEventsWithStartDate:startOfDay endDate:endOfDay calendars:calendars];
    
    const NSArray *const events = [[CalendarEventStore sharedInstance] eventsMatchingPredicate:predicate];
    
    self.tableData = [events sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
    
    [self.tableView reloadData];
}

- (void)moveByDays:(const NSInteger)days {
    NSDateComponents *components = [NSDateComponents new];
    components.day = days;

    self.dayBeingDisplayed = [self.calendar dateByAddingComponents:components toDate:self.dayBeingDisplayed options:0];
}

- (void)setDayBeingDisplayed:(NSDate *)dayBeingDisplayed {
    _dayBeingDisplayed = dayBeingDisplayed;
    
    if (self.team)
        [self loadCalendarForTeam];
    else
        [self loadAllTeamCalendars];
}

#pragma mark - === Table View === -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const EKEvent *const event = self.tableData[indexPath.row];

    CalendarListCell *cell;

    if (event == nil) {
        // No calendar appointments for today
        cell = [tableView dequeueReusableCellWithIdentifier:@"empty" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"NO_CALENDAR_EVENTS", @"Table row saying there are no calendar events for the currently displayed date");
        return cell;
    } else if (event.allDay) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"allDay" forIndexPath:indexPath];
        cell.start.text = [LocalizedStrings calendarEventSpansAllDay];
    } else {
        const NSUInteger wanted = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSDateComponents *ecomps = [[NSCalendar currentCalendar] components:wanted fromDate:event.startDate];
        NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:wanted fromDate:self.dayBeingDisplayed];
        
        const BOOL startsToday = ecomps.day == todayDateComponents.day && ecomps.month == todayDateComponents.month && ecomps.year == todayDateComponents.year && ecomps.era == todayDateComponents.era;

        ecomps = [[NSCalendar currentCalendar] components:wanted fromDate:event.endDate];
        const BOOL endsToday = ecomps.day == todayDateComponents.day && ecomps.month == todayDateComponents.month && ecomps.year == todayDateComponents.year && ecomps.era == todayDateComponents.era;

        if (startsToday && endsToday) {
            // It's a normal event on the current day
            cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
            cell.start.text = [self.dateFormatter stringFromDate:event.startDate];
            cell.end.text = [self.dateFormatter stringFromDate:event.endDate];
        } else if (!(startsToday || endsToday)) {
            // It starts prior to today and ends after today, so just say all day
            cell = [tableView dequeueReusableCellWithIdentifier:@"allDay" forIndexPath:indexPath];
            cell.start.text = [LocalizedStrings calendarEventSpansAllDay];
        } else if (startsToday) {
            // It starts today, but goes into tomorrow, so don't show an end date
            cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
            cell.start.text = [self.dateFormatter stringFromDate:event.startDate];
            cell.end.text = @"";
        } else {
            // It started prior to today, to start should sayd ENDS per Apple example.
            cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
            cell.start.text = NSLocalizedString(@"CALENDAR_SPAN_EVENT_ENDS", @"The text Apple uses to mark the end of an event that spans multiple days");
            cell.end.text = [self.dateFormatter stringFromDate:event.endDate];
        }
    }

    cell.title.text = event.title;
    cell.location.text = event.location;

    cell.colorBar.backgroundColor = [UIColor colorWithCGColor:event.calendar.CGColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Done here just so we don't have to do it to every cell type in both device types.
    [self performSegueWithIdentifier:@"editExistingEvent" sender:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    const NSInteger count = [self.tableData count];
    return count ? count : 1;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    const EKEvent *const event = self.tableData[indexPath.row];
    if (event == nil)
        return nil;
    else
        return indexPath;
}

#pragma mark - === Segues === -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editExistingEvent"]) {
        NSIndexPath *ip = sender;
        
        GSEventEditorViewController *vc = [segue realDestinationViewController];
        vc.event = self.tableData[ip.row];

        if (self.team)
            vc.team = self.team;
        else
            vc.team = [Team teamForCalendarEvent:vc.event managedObjectContext:self.managedObjectContext];
    }
}

@end
