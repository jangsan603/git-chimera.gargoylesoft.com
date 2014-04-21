//
//  CalendarEventStore.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/12/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@interface CalendarEventStore : EKEventStore

+ (instancetype)sharedInstance;

- (void)importWebEvents:(const NSDictionary *const)webData managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSArray *)allocTeamCalendarsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
