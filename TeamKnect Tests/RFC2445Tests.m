//
//  TeamKnect_Tests.m
//  TeamKnect Tests
//
//  Created by Scott Grosch on 4/4/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

// http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html#4.8.5.4

// select regexp_replace(rfc2445, E'\\n', '\n', 'g') from calendar

#import <XCTest/XCTest.h>
#import <EventKit/EventKit.h>
#import "CalendarEventStore.h"
#import "NSDate+DebugStrings.h"
#import "EKEvent+rfc2445.h"
#import "TestsHelper.h"
#import "Sport.h"
#import "Team+Category.h"
#import "AppDelegate.h"

@interface RFC2445Tests : XCTestCase {
    NSArray *exclusions;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) EKCalendar *eventCalendar;
@property (nonatomic, strong) EKEvent *event;
@end

@implementation RFC2445Tests

- (void)setUp
{
    [super setUp];

    self.managedObjectContext = [TestsHelper managedObjectContextForTests];
    
    Sport *sport = [NSEntityDescription insertNewObjectForEntityForName:@"Sport" inManagedObjectContext:self.managedObjectContext];
    sport.name = @"Soccer";
    sport.sql_ident = @1;
    
    Team *team = [NSEntityDescription insertNewObjectForEntityForName:@"Team" inManagedObjectContext:self.managedObjectContext];
    team.sql_ident = @1;
    team.name = @"Test Team";
    team.zip = @"97229";
    team.sport = sport;
    team.calendarIdentifier = self.eventCalendar.calendarIdentifier;
    
    [team createCalendar];
    
    XCTAssertNotNil([CalendarEventStore sharedInstance], @"No event store");
    
    self.eventCalendar = [[CalendarEventStore sharedInstance] calendarWithIdentifier:team.calendarIdentifier];
    XCTAssertNotNil(self.eventCalendar, @"No team calendar");
    
    self.event = [EKEvent eventWithEventStore:[CalendarEventStore sharedInstance]];
    self.event.calendar = self.eventCalendar;
    
    NSError *error;
    BOOL success = [self.managedObjectContext save:&error];
    XCTAssert(success, @"%@", error);
}

- (void)tearDown
{
    [super tearDown];

    NSError *error = nil;
    if (![[CalendarEventStore sharedInstance] removeCalendar:self.eventCalendar commit:YES error:&error])
        XCTFail(@"Unable to remove calendar: %@", error);
}

#pragma mark - === Helper Functions === -

NSDateComponents *dateComponents(NSInteger year, NSInteger month, NSInteger day, NSInteger hour, NSInteger minute, NSString *timezoneName) {
    NSDateComponents *components = [NSDateComponents new];
    components.year = year;
    components.month = month;
    components.day = day;
    components.hour = hour;
    components.minute = minute;

    if (timezoneName) {
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:timezoneName];
        if (tz)
            components.timeZone = tz;
        else {
            NSLog(@"Invalid timezone name '%@'.  Defaulting to Europe/London", timezoneName);
            components.timeZone = [NSTimeZone timeZoneWithName:@"Europe/London"];
        }
    }
    
    return components;
}

NSDate *dateFromSpec(NSInteger year, NSInteger month, NSInteger day, NSInteger hour, NSInteger minute) {
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    });
    
    return [calendar dateFromComponents:dateComponents(year, month, day, hour, minute, nil)];
}

NSDate *dateFromSpecWithTZ(NSInteger year, NSInteger month, NSInteger day, NSInteger hour, NSInteger minute, NSString *timezoneName) {
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    });
    
    return [calendar dateFromComponents:dateComponents(year, month, day, hour, minute, timezoneName)];
}

NSDate *dateFromSpecZ(NSInteger year, NSInteger month, NSInteger day, NSInteger hour, NSInteger minute) {
    return dateFromSpecWithTZ(year, month, day, hour, minute, @"Europe/London");
}

NSDate *dateFromSpecNewYork(NSInteger year, NSInteger month, NSInteger day, NSInteger hour, NSInteger minute) {
    return dateFromSpecWithTZ(year, month, day, hour, minute, @"America/New_York");
}

NSDate *dateFromSpecPortland(NSInteger year, NSInteger month, NSInteger day, NSInteger hour, NSInteger minute) {
    return dateFromSpecWithTZ(year, month, day, hour, minute, @"America/Los_Angeles");
}

- (NSString *)format:(NSDate *)date {
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (BOOL)rruleString:(const EKRecurrenceRule *const)rule matches:(const NSString *const)str {
    const NSString *const desc = [rule description];
    const NSRange rng = [desc rangeOfString:@"RRULE"];
    if (rng.location == NSNotFound)
        return NO;
    
    NSArray *const mine = [str componentsSeparatedByString:@";"];
    NSArray *const theirs = [[desc substringFromIndex:rng.location + 6] componentsSeparatedByString:@";"];
    
    NSMutableSet *const theirSet = [NSMutableSet setWithArray:theirs];
    [theirSet removeObject:@"INTERVAL=1"];
    [theirSet removeObject:@"WKST=SU"];
    
    NSMutableSet *const mySet = [NSMutableSet setWithArray:mine];
    [mySet removeObject:@"INTERVAL=1"];
    [mySet removeObject:@"WKST=SU"];
    
    if (![theirSet isEqualToSet:mySet]) {
        NSLog(@"Event object:  %@", theirSet);
        NSLog(@"String passed: %@", mySet);
        return NO;
    } else
        return YES;
}

- (NSArray *)eventsFromRfc2445:(const NSString *const)rfc2445 start:(NSDate *const)start end:(NSDate *const)end {
    NSDictionary *dict = @{@"1" : @[
                                   @{
                                       @"sql_ident" : @1,
                                       @"team_id" : @1,
                                       @"modified" : @(1397072699.61707),
                                       @"rfc2445" : rfc2445
                                       }
                                   ]
                           };
    
    [[CalendarEventStore sharedInstance] importWebEvents:dict managedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [[CalendarEventStore sharedInstance] predicateForEventsWithStartDate:start
                                                                 endDate:end
                                                               calendars:@[self.eventCalendar]];
    
    return [[CalendarEventStore sharedInstance] eventsMatchingPredicate:predicate];
}

#pragma mark - === Recurrence Pattern Tests === -

- (void)testDailyForTenOccurrences
{
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970902T090000\r\nRRULE:FREQ=DAILY;COUNT=10" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    
    XCTAssert(exclusions.count == 0, @"Should not have exclusions");
    
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyDaily, @"Rule should recur daily.");
    
    EKRecurrenceEnd *end = rule.recurrenceEnd;
    XCTAssertNotNil(end, @"Rule should not recur forever");
    XCTAssert(end.occurrenceCount == 10, @"Rule should recur 10 times");

    XCTAssert([self rruleString:rule matches:@"FREQ=DAILY;COUNT=10"], @"Recurrence rules don't match");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 2, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
}

- (void)testDailyUntilDecember24_1997 {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970902T090000\r\nRRULE:FREQ=DAILY;UNTIL=19971224T000000Z" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyDaily, @"Rule should recur daily.");

    XCTAssertNotNil(rule.recurrenceEnd, @"Rule should not recur forever");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 2, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=DAILY;UNTIL=19971224T000000Z"], @"My rule '%@' does not match their rule 'FREQ=DAILY;UNTIL=19971224T000000Z'", rule);
}

- (void)testEveryOtherDayForever {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970902T090000\r\nRRULE:FREQ=DAILY;INTERVAL=2" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 2, @"Should recur every other day");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyDaily, @"Rule should recur daily.");

    XCTAssertNil(rule.recurrenceEnd, @"Rule should never end");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 2, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=DAILY;INTERVAL=2"], @"Recurrence rules don't match");
}

- (void)testEvery10Days5Occurrences {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970902T090000\r\nRRULE:FREQ=DAILY;INTERVAL=10;COUNT=5" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 10, @"Should recur every 10th day");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyDaily, @"Rule should recur daily.");
    
    EKRecurrenceEnd *end = rule.recurrenceEnd;
    XCTAssertNotNil(end, @"Rule should not recur forever");
    XCTAssert(end.occurrenceCount == 5, @"Rule should recur 5 times");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 2, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=DAILY;INTERVAL=10;COUNT=5"], @"Recurrence rules don't match");
}

- (void)testWeeklyForTenOccurrences
{
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970902T090000\r\nRRULE:FREQ=WEEKLY;COUNT=10" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyWeekly, @"Rule should recur weekly.");
    
    EKRecurrenceEnd *end = rule.recurrenceEnd;
    XCTAssertNotNil(end, @"Rule should not recur forever");
    XCTAssert(end.occurrenceCount == 10, @"Rule should recur 10 times");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 2, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=WEEKLY;COUNT=10"], @"Recurrence rules don't match");
}

#if 0
- (void)testWeeklyOnTuesdayAndThursdayFor5Weeks {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970902T090000\r\nRRULE:FREQ=WEEKLY;UNTIL=19971007T000000Z;BYDAY=TU,TH" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyWeekly, @"Rule should recur weekly.");
    
    XCTAssertNotNil(rule.recurrenceEnd, @"Rule should not recur forever");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 2, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);

    // TODO: Figure out why this is coming back with 19971006T23
    XCTAssert([self rruleString:rule matches:@"FREQ=WEEKLY;INTERVAL=1;UNTIL=19971007T000000Z;BYDAY=TU,TH"], @"Wrong rule: %@", rule);
}
#endif

- (void)testWeeklyOnTuesdayAndThursdayFor5WeeksPart2 {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970902T090000\r\nRRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyWeekly, @"Rule should recur weekly.");

    EKRecurrenceEnd *end = rule.recurrenceEnd;
    XCTAssertNotNil(end, @"Rule should not recur forever");
    XCTAssert(end.occurrenceCount == 10, @"Should recur 10 times.");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 2, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH"], @"Recurrence rules don't match");
}

- (void)testEveryFriday13ForeverExceptSeptember2 {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970902T090000\r\nEXDATE;TZID=America/New_York:19970902T090000\r\nRRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13" exclusions:&exclusions];
    
    XCTAssert(exclusions.count == 1, @"Must have one exclusion.");
    XCTAssert([dateFromSpecNewYork(1997, 9, 2, 9, 0) isEqualToDate:exclusions[0]], @"Must exclude 9/2/1997");
    
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyMonthly, @"Rule should recur monthly.");
    
    XCTAssertNil(rule.recurrenceEnd, @"Recurrence should never end.");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 2, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13"], @"Recurrence rules don't match");
}

- (void)testEveryDayInJanuaryFor3Years {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19980101T090000\r\nRRULE:FREQ=YEARLY;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyYearly, @"Rule should recur yearly.");
    
    EKRecurrenceEnd *end = rule.recurrenceEnd;
    XCTAssertNotNil(end, @"Rule should not recur forever");
    
    NSDate *date = dateFromSpecNewYork(1998, 1, 1, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=YEARLY;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA"], @"Recurrence rules don't match");
}

- (void)testEveryDayInJanuaryFor3YearsPart2 {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19980101T090000\r\nRRULE:FREQ=DAILY;UNTIL=20000131T090000Z;BYMONTH=1" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyDaily, @"Rule should recur daily.");
    
    EKRecurrenceEnd *end = rule.recurrenceEnd;
    XCTAssertNotNil(end, @"Rule should not recur forever");
    
    NSDate *date = dateFromSpecNewYork(1998, 1, 1, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=DAILY;UNTIL=20000131T090000Z;BYMONTH=1"], @"Recurrence rules don't match");
}

- (void)testPresidentialElectionDay {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19961105T090000\r\nRRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 4, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyYearly, @"Rule should recur yearly.");
    
    XCTAssertNil(rule.recurrenceEnd, @"Recurrence should never end.");
    
    NSDate *date = dateFromSpecNewYork(1996, 11, 5, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8"], @"Recurrence rules don't match");
}

- (void)test3rdInstanceIntoMonthOfTuWeTh {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970904T090000\r\nRRULE:FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyMonthly, @"Rule should recur yearly.");

    EKRecurrenceEnd *end = rule.recurrenceEnd;
    XCTAssertNotNil(end, @"Rule should not recur forever");
    XCTAssert(end.occurrenceCount == 3, @"Rule should recur 3 times");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 4, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3"], @"Recurrence rules don't match");
}

- (void)test2ndToLastWeekdayOfMonth {
    [self.event populateFromRfc2445string:@"DTSTART;TZID=America/New_York:19970929T090000\r\nRRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=2" exclusions:&exclusions];
    
    XCTAssertFalse(exclusions.count, @"Must not have exclusion dates");
    
    XCTAssert(self.event.hasRecurrenceRules, @"Event does not have recurrence rule");
    XCTAssert(self.event.recurrenceRules.count == 1, @"Event should not have multiple recurrence rules");
    
    EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
    XCTAssert(rule.interval == 1, @"Rule should have interval of 1");
    XCTAssert(rule.frequency == EKRecurrenceFrequencyMonthly, @"Rule should recur monthly.");
    
    NSDate *date = dateFromSpecNewYork(1997, 9, 29, 9, 0);
    XCTAssert([self.event.startDate isEqualToDate:date], @"Date must start '%@', not '%@'", [self format:date], [self format:self.event.startDate]);
    
    XCTAssert([self rruleString:rule matches:@"FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=2"], @"Recurrence rules don't match");
}

#pragma mark === Modified Recurrence Changes ===

- (void)noruntestASDF {
    NSString *fullBlock = @"BEGIN:VEVENT\r\nCREATED:20140409T200208Z\r\nUID:047BC79F-E432-496D-96D9-CC754553748F\r\nRRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20140418T065959Z\r\nDTEND;TZID=America/Los_Angeles:20140409T150000\r\nTRANSP:OPAQUE\r\nSUMMARY:billybob\r\nDTSTART;TZID=America/Los_Angeles:20140409T140000\r\nDTSTAMP:20140409T200907Z\r\nSEQUENCE:4\r\nEND:VEVENT\r\nBEGIN:VEVENT\r\nCREATED:20140409T200208Z\r\nUID:047BC79F-E432-496D-96D9-CC754553748F\r\nDTEND;TZID=America/Los_Angeles:20140415T150000\r\nTRANSP:OPAQUE\r\nSUMMARY:billybob\r\nDTSTART;TZID=America/Los_Angeles:20140415T140000\r\nDTSTAMP:20140409T200236Z\r\nLOCATION:The 15th's location\r\nSEQUENCE:5\r\nRECURRENCE-ID;TZID=America/Los_Angeles:20140415T140000\r\nEND:VEVENT";
    
    // Split the string on \r\n (componentsSeparatedByString)
    // Loop through the lines...
    // Whenever you find BEGIN:VEVENT you are starting a new event.  Therefore blank out (i.e. create new) the NSMutableArray
    // so that you can populate it.
    // Loop until you find an END:VEVENT line pushing each line into an NSMutableArray as you go.
    // Once you find the END:VEVENT, join that NSMutableArray by \r\n and assign to firstEventBlock (look at the NSMutableArray documentation to figure out how to do a join.  Option+click on the NSMutableArray type to get help)
    // Keep pulling in lines until you hit the second END:VEVENT block.
    // join it by \r\n and assign to secondEventBlock

    NSString *firstEventBlock;
    NSString *secondEventBlock;
    NSString *recurrenceId;
    NSString *untilDateString;
    NSMutableArray *array;
    
    NSArray *lines = [fullBlock componentsSeparatedByString:@"\r\n"];
    // lines[0] = @"BEGIN:VEVENT";
    // lines[1] = @"CREATED:....";
    // lines[2] = @"UID:....";
    
    for (NSString *line in lines) {
        if ([line isEqualToString:@"BEGIN:VEVENT"]) {
            array = [NSMutableArray new];
            
        } else if ([line isEqualToString:@"END:VEVENT"])  {
            if (firstEventBlock == nil)
                firstEventBlock = [array componentsJoinedByString:@"\r\n"];
            else
                secondEventBlock =[array componentsJoinedByString:@"\r\n"];
        } else if ([line hasPrefix:@"RECURRENCE-ID"]) {
            recurrenceId = line;
            [array addObject:line];
        } else if ([line hasPrefix:@"UNTIL="]) {
            untilDateString = line;
            [array addObject:line];
        } else {
            [array addObject:line];
        }
    }
    
    XCTAssert([firstEventBlock isEqualToString:@"CREATED:20140409T200208Z\r\nUID:047BC79F-E432-496D-96D9-CC754553748F\r\nRRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20140418T065959Z\r\nDTEND;TZID=America/Los_Angeles:20140409T150000\r\nTRANSP:OPAQUE\r\nSUMMARY:billybob\r\nDTSTART;TZID=America/Los_Angeles:20140409T140000\r\nDTSTAMP:20140409T200907Z\r\nSEQUENCE:4"], @"firstEventBlock got built wrong");
    
    
    XCTAssert([secondEventBlock isEqualToString:@"CREATED:20140409T200208Z\r\nUID:047BC79F-E432-496D-96D9-CC754553748F\r\nDTEND;TZID=America/Los_Angeles:20140415T150000\r\nTRANSP:OPAQUE\r\nSUMMARY:billybob\r\nDTSTART;TZID=America/Los_Angeles:20140415T140000\r\nDTSTAMP:20140409T200236Z\r\nLOCATION:The 15th's location\r\nSEQUENCE:5\r\nRECURRENCE-ID;TZID=America/Los_Angeles:20140415T140000"], @"secondEventBlock got built wrong");
    
    
    EKEvent *recurringEvent = [EKEvent eventWithEventStore:[CalendarEventStore sharedInstance]];
    [recurringEvent populateFromRfc2445string:firstEventBlock exclusions:&exclusions];
    XCTAssert(exclusions.count == 0, @"No exclusions should be here");
    
    EKEvent *oneOffEvent = [EKEvent eventWithEventStore:[CalendarEventStore sharedInstance]];
    [oneOffEvent populateFromRfc2445string:secondEventBlock exclusions:&exclusions];
    XCTAssert(exclusions.count == 0, @"No exclusions should be here");
    
    BOOL hasTimeComp;
    NSDate *origRecurrenceDate = [EKEvent dateFromString:recurrenceId hasTimeComponent:&hasTimeComp];
    
    BOOL hasTimeComp2;
    NSDate *origUntilDate = [EKEvent dateFromString:untilDateString hasTimeComponent:&hasTimeComp2];
    
    NSPredicate *predicate = [[CalendarEventStore sharedInstance] predicateForEventsWithStartDate:recurringEvent.startDate
                                                                                   endDate:origUntilDate
                                                                                 calendars:nil];
    NSArray *events = [[CalendarEventStore sharedInstance] eventsMatchingPredicate:predicate];
    
    // if oneOffEvent's title != recurringEvent title then grab the event at origRecurrenceDate
    // That's event's title should be oneOffEvent's title, not recurringEvent title.
    //
    // if oneOffEvent's location != recurringEvent location then grab the event at origRecurrenceDate
    // That's event's location should be oneOffEvent's location, not recurringEvent location.

    EKEvent *instanceOfChangedEvent = nil;
    for (EKEvent *e in events) {
        if ([e.startDate isEqualToDate:origRecurrenceDate]) {
            instanceOfChangedEvent = e;
            break;
        }
    }
    
    XCTAssertNotNil(instanceOfChangedEvent, @"I was not able to find the event which was modified.");
    
    if (![oneOffEvent.title isEqualToString:recurringEvent.title])
        XCTAssert([oneOffEvent.title isEqualToString:instanceOfChangedEvent.title], @"Wrong title found");

}

- (void)testDifferentLocationEverythingElseSame {
    NSString *fullBlock = @"BEGIN:VEVENT\r\nCREATED:20140409T200208Z\r\nUID:047BC79F-E432-496D-96D9-CC754553748F\r\nRRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20140418T065959Z\r\nDTEND;TZID=America/Los_Angeles:20140409T150000\r\nTRANSP:OPAQUE\r\nSUMMARY:billybob\r\nDTSTART;TZID=America/Los_Angeles:20140409T140000\r\nDTSTAMP:20140409T200907Z\r\nEND:VEVENT\r\nBEGIN:VEVENT\r\nCREATED:20140409T200208Z\r\nUID:047BC79F-E432-496D-96D9-CC754553748F\r\nDTEND;TZID=America/Los_Angeles:20140415T150000\r\nTRANSP:OPAQUE\r\nSUMMARY:billybob\r\nDTSTART;TZID=America/Los_Angeles:20140415T140000\r\nDTSTAMP:20140409T200236Z\r\nLOCATION:The 15th's location\r\nSEQUENCE:5\r\nRECURRENCE-ID;TZID=America/Los_Angeles:20140415T140000\r\nEND:VEVENT";
    
    NSArray *events = [self eventsFromRfc2445:fullBlock start:dateFromSpecPortland(2014, 4, 9, 0, 0) end:dateFromSpecPortland(2014, 4, 19, 23, 59)];
    XCTAssert(events.count == 9, @"9 != %lu", (unsigned long)events.count);
    
    NSDate *modifiedEvent = dateFromSpecPortland(2014, 4, 15, 14, 0);
    for (EKEvent *event in events) {
        if ([event.startDate isEqualToDate:modifiedEvent]) {
            XCTAssert(event.location != nil && [event.location isEqualToString:@"The 15th's location"], @"Should have the 15th's location: %@", event);
        } else {
            XCTAssertNil(event.location, @"Should have no location: %@", event);
        }
    }
}

- (void)testNoDuplicatesWithOneDifferentLocation {
    NSString *fullBlock = @"BEGIN:VEVENT\r\nCREATED:20140409T200208Z\r\nUID:047BC79F-E432-496D-96D9-CC754553748F\r\nRRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20140418T065959Z\r\nDTEND;TZID=America/Los_Angeles:20140409T150000\r\nTRANSP:OPAQUE\r\nSUMMARY:billybob\r\nDTSTART;TZID=America/Los_Angeles:20140409T140000\r\nDTSTAMP:20140409T200907Z\r\nEND:VEVENT\r\nBEGIN:VEVENT\r\nCREATED:20140409T200208Z\r\nUID:047BC79F-E432-496D-96D9-CC754553748F\r\nDTEND;TZID=America/Los_Angeles:20140415T150000\r\nTRANSP:OPAQUE\r\nSUMMARY:billybob\r\nDTSTART;TZID=America/Los_Angeles:20140415T140000\r\nDTSTAMP:20140409T200236Z\r\nLOCATION:The 15th's location\r\nSEQUENCE:5\r\nRECURRENCE-ID;TZID=America/Los_Angeles:20140415T140000\r\nEND:VEVENT";
    
    NSDate *const start = dateFromSpecPortland(2014, 4, 9, 0, 0);
    NSDate *const end = dateFromSpecPortland(2014, 4, 19, 23, 59);
    
    for (int i = 0; i < 10; i++) {
        NSArray *events = [self eventsFromRfc2445:fullBlock start:start end:end];
        XCTAssert(events.count == 9, @"%lu != 9 on iteration %d", (unsigned long)events.count, i + 1);
    }
}

- (void)testCanDeleteFirstOccurrence {
    EKRecurrenceEnd *end = [EKRecurrenceEnd recurrenceEndWithEndDate:dateFromSpec(2014, 4, 19, 12, 0)];
    EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 end:end];
    
    EKEvent *recurring = [EKEvent eventWithEventStore:[CalendarEventStore sharedInstance]];
    recurring.startDate = dateFromSpec(2014, 4, 12, 12, 0);
    recurring.endDate = dateFromSpec(2014, 4, 12, 13, 0);
    recurring.recurrenceRules = @[rule];
    recurring.calendar = self.eventCalendar;
    
    NSError *error;
    if (![[CalendarEventStore sharedInstance] saveEvent:recurring span:EKSpanFutureEvents commit:YES error:&error]) {
        NSLog(@"SAVE: %@", error);
        return;
    }
    
    NSPredicate *firstOccurrence = [[CalendarEventStore sharedInstance] predicateForEventsWithStartDate:dateFromSpec(2014, 4, 12, 12, 0)
                                                                                                endDate:dateFromSpec(2014, 4, 12, 13, 0)
                                                                                              calendars:@[self.eventCalendar]];
    
    NSArray *events = [[CalendarEventStore sharedInstance] eventsMatchingPredicate:firstOccurrence];
    
    EKEvent *first = [events firstObject];
    
    if (![[CalendarEventStore sharedInstance] removeEvent:first span:EKSpanThisEvent commit:YES error:&error])
        NSLog(@"Remove failed: %@", error);
}

- (void)testOneEventChangedToAllDay {
    NSString *fullBlock = @"BEGIN:VEVENT\r\nUID:D3C5E1B5-305C-46FE-9B67-29B0A9B47F61@fe80::56e4:3aff:feef:893f\r\nDTSTAMP:20140413T043914Z\r\nCREATED:20140413T043837Z\r\nDTSTART:20140413T200000Z\r\nDTEND:20140413T210000Z\r\nSUMMARY:Daily 4/13-4/17\r\nRRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20140418T043025Z\r\nEND:VEVENT\r\nBEGIN:VEVENT\r\nUID:D3C5E1B5-305C-46FE-9B67-29B0A9B47F61@fe80::56e4:3aff:feef:893f\r\nDTSTAMP:20140413T043914Z\r\nCREATED:20140413T043914Z\r\nDTSTART;VALUE=DATE:20140415\r\nDTEND;VALUE=DATE:20140416\r\nSUMMARY:Daily 4/13-4/17\r\nRECURRENCE-ID:20140415T200000Z\r\nEND:VEVENT";

    NSArray *events = [self eventsFromRfc2445:fullBlock start:dateFromSpecPortland(2014, 4, 13, 0, 0) end:dateFromSpecPortland(2014, 4, 17, 23, 59)];
    XCTAssert(events.count == 5, @"5 != %lu", (unsigned long)events.count);
    
}

- (void)testAllDayApril6to12 {
    NSString *fullBlock = @"BEGIN:VEVENT\r\nCREATED:20140413T204526Z\r\nUID:1789B131-6768-4D42-898A-4155F265C7DD\r\nRRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20140412\r\nDTEND;VALUE=DATE:20140407\r\nTRANSP:TRANSPARENT\r\nSUMMARY:6-12\r\nDTSTART;VALUE=DATE:20140406\r\nDTSTAMP:20140413T204553Z\r\nEND:VEVENT";

    NSArray *events = [[self eventsFromRfc2445:fullBlock start:dateFromSpecPortland(2014, 4, 1, 0, 0) end:dateFromSpecPortland(2014, 4, 30, 23, 59)] sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
    
    XCTAssert(events.count == 7, @"%lu != 7", (unsigned long)events.count);
    
    for (EKEvent *event in events) {
        XCTAssert(event.allDay, @"%@ is not all day", event);
    }
}

- (void)testAllDayEndsProperly {
    NSDate *start = dateFromSpecPortland(2014, 4, 13, 1, 0);
    NSDate *endDate = dateFromSpecPortland(2014, 4, 13, 2, 0);
    
    self.event.title = @"foo";
    self.event.startDate = start;
    self.event.endDate = endDate;
    self.event.allDay = YES;
    
    EKRecurrenceEnd *end = [EKRecurrenceEnd recurrenceEndWithEndDate:dateFromSpecPortland(2014, 4, 18, 1, 0)];
    self.event.recurrenceRules = @[[[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:end]];
    
    NSError *error;
    if ([[CalendarEventStore sharedInstance] saveEvent:self.event span:EKSpanFutureEvents error:&error])
        NSLog(@"save failed: %@", error);
    
    NSPredicate *predicate = [[CalendarEventStore sharedInstance] predicateForEventsWithStartDate:dateFromSpec(2014, 4, 1, 0, 0)
                                                                                          endDate:dateFromSpec(2014, 4, 30, 1, 0)
                                                                                        calendars:@[self.eventCalendar]];
  
    const NSArray *const events = [[CalendarEventStore sharedInstance] eventsMatchingPredicate:predicate];
    XCTAssert(events.count == 6, @"Should have 6 events, not %lu", (unsigned long)events.count);
}

@end
