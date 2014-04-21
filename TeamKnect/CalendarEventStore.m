//
//  CalendarEventStore.m
//  TeamKnect
//
//  Created by Scott Grosch on 4/12/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarEventStore.h"
#import "CalendarMap+Category.h"
#import "CalendarMapExtras.h"
#import "EKEvent+rfc2445.h"
#import "Team+Category.h"

@implementation CalendarEventStore

+ (instancetype)sharedInstance {
    static CalendarEventStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[[self class] alloc] init];
    });
    
    return store;
}

+ (BOOL)stringA:(NSString *)a doesNotMatch:(NSString *)b {
    if (a == nil && b != nil)
        return YES;
    
    if (a != nil && b == nil)
        return YES;
    
    if (a == nil && b == nil)
        return NO;
    
    return ![a isEqualToString:b];
}

- (EKEvent *)findMatchingEvent:(const RFC2445 *const)rfc inCalendar:(const EKCalendar *const)calendar {
    NSPredicate *predicate = [self predicateForEventsWithStartDate:rfc.startDate endDate:rfc.endDate calendars:@[calendar]];
    for (EKEvent *event in [self eventsMatchingPredicate:predicate]) {
        if ([CalendarEventStore stringA:event.title doesNotMatch:rfc.summary])
            continue;
        
        if ([CalendarEventStore stringA:event.location doesNotMatch:rfc.location])
            continue;
        
        if ([CalendarEventStore stringA:event.notes doesNotMatch:rfc.notes])
            continue;
        
        if (event.allDay != rfc.allDay)
            continue;
        
        if (rfc.recurrenceRule) {
            if (!event.hasRecurrenceRules)
                continue;
            
            EKRecurrenceRule *eventRecurrence = [event.recurrenceRules firstObject];
            EKRecurrenceRule *matchRecurrence = rfc.recurrenceRule;
            
            if (eventRecurrence.frequency != matchRecurrence.frequency)
                continue;
            
            if (eventRecurrence.interval != matchRecurrence.interval)
                continue;
            
            EKRecurrenceEnd *eventEnd = eventRecurrence.recurrenceEnd;
            EKRecurrenceEnd *matchEnd = matchRecurrence.recurrenceEnd;
            
            if (eventEnd) {
                if (!matchEnd)
                    continue;
                
                if ([eventEnd.endDate compare:matchEnd.endDate] != NSOrderedSame)
                    continue;
            } else if (matchEnd)
                continue;
        } else if (event.hasRecurrenceRules)
            continue;
        
        return event;
    }
    
    return nil;
}

+ (NSDictionary *)eventsFromRfc2445:(const NSString *const)rfc2445 {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSMutableArray *current;
    
    BOOL mustHaveSequence = NO;
    int seq;
    NSNumber *sequence;
    NSString *recurrenceId;
    
    BOOL insideEvent = NO;
    
    for (NSString *const line in [rfc2445 componentsSeparatedByString:@"\r\n"]) {
        if (insideEvent) {
            if ([line isEqualToString:@"END:VEVENT"]) {
                insideEvent = NO;
                
                // Calendar items with multiple parts MUST have a sequence so we know to 'merge' them.  If
                // there is no sequence on it, because we screwed up during RFC2445 generation, then just fake
                // one.
                if (mustHaveSequence && (!sequence || [sequence isEqualToNumber:@0]))
                    sequence = @1;
                
                mustHaveSequence = YES;
                
                if (dict[sequence] == nil)
                    dict[sequence] = [NSMutableArray new];
                
                [dict[sequence] addObject:@[recurrenceId ? recurrenceId : [NSNull null], [current componentsJoinedByString:@"\r\n"]]];
                
                continue;
            }
            
            if (sscanf([line UTF8String], "SEQUENCE:%d", &seq) == 1)
                sequence = @(seq);
            else if (([line hasPrefix:@"RECURRENCE-ID:"] || [line hasPrefix:@"RECURRENCE-ID;"]) && line.length > 14)
                recurrenceId = line;
            
            [current addObject:line];
        } else {
            if ([line isEqualToString:@"BEGIN:VEVENT"]) {
                sequence = @0;
                recurrenceId = nil;
                insideEvent = YES;
                current = [NSMutableArray new];
            } else
                [current addObject:line];
        }
    }
    
    return dict;
}

- (void)importWebEvents:(const NSDictionary *const)webData managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    request.predicate = [NSPredicate predicateWithFormat:@"calendarIdentifier != nil"];
    
    NSMutableDictionary *teams = [NSMutableDictionary new];
    NSArray *ary = [managedObjectContext executeFetchRequest:request error:NULL];
    if (ary.count == 0)
        return;
    
    for (const Team *const team in ary)
        teams[team.sql_ident] = team;
    
    NSMutableDictionary *calendarMap = [NSMutableDictionary new];
    
    request = [[NSFetchRequest alloc] initWithEntityName:@"CalendarMap"];
    request.relationshipKeyPathsForPrefetching = @[@"extras"];
    for (const CalendarMap *const map in [managedObjectContext executeFetchRequest:request error:NULL])
        calendarMap[map.sql_ident] = map;
    
    [webData enumerateKeysAndObjectsUsingBlock:^(const NSString *const teamSqlIdent, const NSArray *const events, BOOL *stop) {
        for (const NSDictionary *const eventData in events) {
            NSNumber *const sql_ident = @([eventData[@"sql_ident"] longValue]);
            const Team *const team = teams[@((long)[teamSqlIdent longLongValue])];
            
            CalendarMap *map = calendarMap[sql_ident];
            if (map) {
                // This is an existing calendar item, and we need to update it
                EKEvent *event = [self eventWithIdentifier:map.eventIdentifier];
                
                NSError *error;
            
                if (![self removeEvent:event span:EKSpanFutureEvents error:&error] && error)
                    NSLog(@"Unable to remove orig event: %@", error);
                
                for (CalendarMapExtras *extra in [map.extras allObjects]) {
                    event = [self eventWithIdentifier:extra.eventIdentifier];
                    if (![self removeEvent:event span:EKSpanThisEvent error:&error] && error)
                        NSLog(@"Unable to remove extra event: %@", error);
                }
                
                [managedObjectContext deleteObject:map];
                [calendarMap removeObjectForKey:sql_ident];
            }
            
            [self createEventsForNewCalendarItem:eventData team:team sqlIdent:sql_ident];
        }
    }];
}

- (void)createEventsForNewCalendarItem:(const NSDictionary *const)eventData team:(const Team *const)team sqlIdent:(NSNumber *const)sqlIdent {
    const NSCalendar *const nsCalendar = [NSCalendar currentCalendar];
    
    EKCalendar *calendar = [team calendarForTeam];
    NSDictionary *data = [CalendarEventStore eventsFromRfc2445:eventData[@"rfc2445"]];
    NSManagedObjectContext *managedObjectContext = team.managedObjectContext;
    
    NSDateFormatter *dateAndTimeFormatter = [EKEvent dateAndTimeFormatter];
    NSDateFormatter *dateFormatter = [EKEvent dateOnlyFormatter];
    
    // Have to sort by keys because it's critical that sequence #0 be first.  The others don't matter, but 0 has gotta come first.
    const NSArray *const keys = [[data allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    // Now loop through each key
    __block CalendarMap *map = nil;
    
    EKEvent *master = nil;
    
    for (NSNumber *const sequence in keys) {
        for (const NSArray *const element in data[sequence]) {
            // The elements are all tuples where the first element is the recurrence-id and the second is the RFC2445 string.
            id first = [element firstObject];
            NSString *recurrenceId = first == [NSNull null] ? nil : first;
            
            NSString *rfc2445 = [element lastObject];
            
            // This can happen if garbage gets saved to the server.  It's really a null object, but since the
            // server gives us this object as a string, ObjC puts the string @"(null)" in there.
            if ([rfc2445 isEqualToString:@"(null)"])
                continue;
            
            EKEvent *event = [EKEvent eventWithEventStore:self];
            event.calendar = calendar;
            
            NSArray *exclusions = [NSMutableArray new];
            [event populateFromRfc2445string:rfc2445 exclusions:&exclusions];
            
            if (!event.startDate) {
                NSLog(@"No start date set for:\n\n%@\n\n%@", [rfc2445 stringByReplacingOccurrencesOfString:@"\r" withString:@""], event);
                continue;
            }
            
            NSError *error;
            
            EKSpan span = event.hasRecurrenceRules ? EKSpanFutureEvents : EKSpanThisEvent;
            
            if (![self saveEvent:event span:span commit:YES error:&error]) {
                // NSLog(@"\n\n\n%s: saveEvent: %@\n%@", __func__, error, event);
                continue;
            }
            
            // Components will contain the time offset from the start to the end
            NSDateComponents *const components = [nsCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                               fromDate:event.startDate
                                                                 toDate:event.endDate
                                                                options:0];
            
            if ([sequence intValue] == 0) {
                // The first RFC2445 block we see sets the primary entry.
                master = event;
                
                [managedObjectContext performBlockAndWait:^{
                    map = [NSEntityDescription insertNewObjectForEntityForName:@"CalendarMap" inManagedObjectContext:managedObjectContext];
                    map.sql_ident = sqlIdent;
                    map.eventIdentifier = event.eventIdentifier;
                    map.uid = [EKEvent uid];
                    map.rfc2445 = rfc2445;
                    map.team = (Team *) team;
                }];
                
                if (exclusions.count) {
                    // Components will contain the time offset from
                    for (NSDate *const exclusion in exclusions) {
                        NSPredicate *const predicate = [self predicateForEventsWithStartDate:exclusion endDate:[nsCalendar dateByAddingComponents:components toDate:exclusion options:0] calendars:@[event.calendar]];
                        
                        for (EKEvent *e in [self eventsMatchingPredicate:predicate])
                            if ([e isEqualToEvent:event]) {
                                [map addExceptionDate:e];
                                [self removeEvent:e span:EKSpanThisEvent error:NULL];
                                break;
                            }
                    }
                }
            } else {
                BOOL hasTimeComponent;
                NSDate *origStart = [EKEvent dateFromString:recurrenceId hasTimeComponent:&hasTimeComponent];
                
                [managedObjectContext performBlockAndWait:^{
                    NSMutableString *str = [[NSMutableString alloc] initWithString:[event toRfc2445WithUID:map.uid]];
                    [str appendFormat:@"\r\nSEQUENCE:%@", sequence];
                    
                    if (hasTimeComponent)
                        [str appendFormat:@"\r\nRECURRENCE-ID:%@", [dateAndTimeFormatter stringFromDate:origStart]];
                    else
                        [str appendFormat:@"\r\nRECURRENCE-ID;VALUE=DATE:%@", [dateFormatter stringFromDate:origStart]];
                    
                    // Any others that exist are extras that we tack onto the main one.
                    CalendarMapExtras *extra = [NSEntityDescription insertNewObjectForEntityForName:@"CalendarMapExtras" inManagedObjectContext:managedObjectContext];
                    extra.rfc2445 = str;
                    extra.calendarMap = map;
                    extra.date = event.startDate;
                    extra.sequence = sequence;
                    extra.eventIdentifier = event.eventIdentifier;
                }];
                
                // This is an exception instance, so remove the original calendar entry for this date.
                NSPredicate *const predicate = [self predicateForEventsWithStartDate:origStart endDate:[nsCalendar dateByAddingComponents:components toDate:origStart options:0] calendars:@[event.calendar]];
                
                for (EKEvent *e in [self eventsMatchingPredicate:predicate])
                    if ([e isEqualToEvent:master]) {
                        NSError *error;
                        
                        if (![self removeEvent:e span:EKSpanThisEvent commit:YES error:&error])
                            NSLog(@"Failed to remove event: %@", error);

                        break;
                    }
            }
        }
    }
    
    [managedObjectContext performBlock:^{
        NSError *error;
        if (![managedObjectContext save:&error])
            NSLog(@"%s: MOC: %@", __func__, error);
    }];
}


- (NSArray *)allocTeamCalendarsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *const request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    request.predicate = [NSPredicate predicateWithFormat:@"calendarIdentifier != nil"];
    request.propertiesToFetch = @[@"calendarIdentifier"];
    
    const NSArray *const teams = [managedObjectContext executeFetchRequest:request error:NULL];
    if (teams.count == 0)
        return nil;
    
    // Remember that a full calendar sync will wipe the calendar's calendarIdentifier for some reason
    NSMutableDictionary *nameToCalendar = [NSMutableDictionary new];
    for (EKCalendar *cal in [self calendarsForEntityType:EKEntityTypeEvent])
        nameToCalendar[cal.title] = cal;
    
    BOOL needToSave = NO;
    
    NSMutableArray *const calendars = [NSMutableArray new];
    
    for (const Team *const team in teams) {
        EKCalendar *cal = [self calendarWithIdentifier:team.calendarIdentifier];
        if (!cal) {
            if ((cal = nameToCalendar[cal.title]) != nil) {
                [calendars addObject:cal];
                team.calendarIdentifier = cal.calendarIdentifier;
                needToSave = YES;
            } else {
                [BlockAlertView okWithMessage:[NSString stringWithFormat:@"Calendar '%@' for '%@' was nil\n\n%@", team.calendarIdentifier, team.name, [[nameToCalendar allKeys] componentsJoinedByString:@","]]];
            }
        } else
            [calendars addObject:cal];
    }
    
    if (needToSave)
        [managedObjectContext performBlock:^{
            [managedObjectContext save:NULL];
        }];
    
    return calendars;
}

@end
