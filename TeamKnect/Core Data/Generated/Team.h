//
//  Team.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SQL.h"

@class CalendarMap, Sport, TeamPerson;

@interface Team : SQL

@property (nonatomic, retain) NSString * calendarIdentifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSSet *people;
@property (nonatomic, retain) Sport *sport;
@property (nonatomic, retain) NSSet *calendarMaps;
@end

@interface Team (CoreDataGeneratedAccessors)

- (void)addPeopleObject:(TeamPerson *)value;
- (void)removePeopleObject:(TeamPerson *)value;
- (void)addPeople:(NSSet *)values;
- (void)removePeople:(NSSet *)values;

- (void)addCalendarMapsObject:(CalendarMap *)value;
- (void)removeCalendarMapsObject:(CalendarMap *)value;
- (void)addCalendarMaps:(NSSet *)values;
- (void)removeCalendarMaps:(NSSet *)values;

@end
