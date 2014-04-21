//
//  Injury.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SQL.h"

@class Person;

@interface Injury : SQL

@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSDate * doi;
@property (nonatomic, retain) NSDate * dor;
@property (nonatomic, retain) NSString * site;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) Person *person;

@end
