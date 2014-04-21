//
//  Team+Category.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/31/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "Team.h"

@interface Team (Category)

+ (Team *)teamForCalendarEvent:(EKEvent *)event managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (void)createCalendar;
- (NSString *)debugDescription;
- (EKCalendar *)calendarForTeam;

@end
