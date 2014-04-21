//
//  Person.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SQL.h"

@class Conversation, Injury, Message, Picture, TeamPerson;

@interface Person : SQL

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * country_of_birth;
@property (nonatomic, retain) NSDate * dob;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * first;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * injury_status;
@property (nonatomic, retain) NSString * last;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * nationality;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSSet *conversations;
@property (nonatomic, retain) NSSet *injuries;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) Picture *picture;
@property (nonatomic, retain) NSSet *teamPerson;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addConversationsObject:(Conversation *)value;
- (void)removeConversationsObject:(Conversation *)value;
- (void)addConversations:(NSSet *)values;
- (void)removeConversations:(NSSet *)values;

- (void)addInjuriesObject:(Injury *)value;
- (void)removeInjuriesObject:(Injury *)value;
- (void)addInjuries:(NSSet *)values;
- (void)removeInjuries:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addTeamPersonObject:(TeamPerson *)value;
- (void)removeTeamPersonObject:(TeamPerson *)value;
- (void)addTeamPerson:(NSSet *)values;
- (void)removeTeamPerson:(NSSet *)values;

@end
