//
//  Message.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SQL.h"

@class Conversation, Person;

@interface Message : SQL

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Conversation *conversation;
@property (nonatomic, retain) Person *sender;

@end
