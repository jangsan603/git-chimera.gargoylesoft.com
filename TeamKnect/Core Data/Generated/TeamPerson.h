//
//  TeamPerson.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SQL.h"

@class Person, Team;

@interface TeamPerson : SQL

@property (nonatomic, retain) NSNumber * jersey;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSNumber * roles;
@property (nonatomic, retain) NSString * shot;
@property (nonatomic, retain) NSString * strengths;
@property (nonatomic, retain) NSString * weaknesses;
@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) Team *team;

@end
