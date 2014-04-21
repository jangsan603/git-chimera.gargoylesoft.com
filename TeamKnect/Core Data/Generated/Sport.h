//
//  Sport.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SQL.h"

@class Team;

@interface Sport : SQL

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *teams;
@end

@interface Sport (CoreDataGeneratedAccessors)

- (void)addTeamsObject:(Team *)value;
- (void)removeTeamsObject:(Team *)value;
- (void)addTeams:(NSSet *)values;
- (void)removeTeams:(NSSet *)values;

@end
