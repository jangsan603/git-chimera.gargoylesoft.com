//
//  Team+Category.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/31/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "Team+Category.h"
#import "Sport.h"
#import <EventKit/EventKit.h>
#import "TeamPerson.h"
#import "AppDelegate.h"

@implementation Team (Category)

- (void)createCalendar {
    EKSource *localSource = nil;
    EKSource *cloudSource = nil;

    EKEventStore *store = [CalendarEventStore sharedInstance];
    
    [store refreshSourcesIfNecessary];
    
    for (EKCalendar *calendar in [store calendarsForEntityType:EKEntityTypeEvent]) {
        if ([calendar.title isEqualToString:self.name]) {
            self.calendarIdentifier = calendar.calendarIdentifier;
            return;
        }
    }
    
    for (EKSource *s in store.sources)
        if (s.sourceType == EKSourceTypeLocal)
            localSource = s;
    // TODO: If we find a CalDAV, but we don't find an iCloud, pop up a list and ask if one of them is
    // iCloud.  If it is, use it.  If not, then go with local store.
        else if (s.sourceType == EKSourceTypeCalDAV && [s.title isEqualToString:@"iCloud"])
            cloudSource = s;

    EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:store];
    calendar.title = self.name;
    calendar.source = cloudSource ? cloudSource : localSource;

    NSError *error;
    if (![store saveCalendar:calendar commit:YES error:&error]) {
        EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        
        NSString *str;
        if (status == EKAuthorizationStatusAuthorized)
            str = @"EKAuthorizationStatusAuthorized";
        else if (status == EKAuthorizationStatusDenied)
            str = @"EKAuthorizationStatusDenied";
        else if (status == EKAuthorizationStatusNotDetermined)
            str = @"EKAuthorizationStatusNotDetermined";
        else if (status == EKAuthorizationStatusRestricted)
            str = @"EKAuthorizationStatusRestricted";
        
        NSLog(@"Failed to create calendar:\n\tCalendar: %@\n\tError: %@\n\tAuthorization: %@\n\tSources: %@", calendar, error, str, store.sources);
    }

    self.calendarIdentifier = calendar.calendarIdentifier;
}

- (EKCalendar *)calendarForTeam {
    return [[CalendarEventStore sharedInstance] calendarWithIdentifier:self.calendarIdentifier];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%p '%@' '%@' '%@'=%@ %lu people, %@", self, self.name, self.zip, self.sport.name, self.sport.sql_ident, (u_long) self.people.count, self.managedObjectContext];
}

+ (Team *)teamForCalendarEvent:(EKEvent *)event managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if (event == nil)
        return nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    request.predicate = [NSPredicate predicateWithFormat:@"calendarIdentifier = %@", event.calendar.calendarIdentifier];
    
    return [[managedObjectContext executeFetchRequest:request error:NULL] firstObject];
}

@end
