//
//  CalendarMap.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SQL.h"

@class CalendarMapExtras, Team;

@interface CalendarMap : SQL

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * eventIdentifier;
@property (nonatomic, retain) NSString * exclusions;
@property (nonatomic, retain) NSString * rfc2445;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSSet *extras;
@property (nonatomic, retain) Team *team;
@end

@interface CalendarMap (CoreDataGeneratedAccessors)

- (void)addExtrasObject:(CalendarMapExtras *)value;
- (void)removeExtrasObject:(CalendarMapExtras *)value;
- (void)addExtras:(NSSet *)values;
- (void)removeExtras:(NSSet *)values;

@end
