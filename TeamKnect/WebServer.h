//
//  WebServer.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WebResponseSuccess)(id data);
typedef void (^WebResponseFailure)(NSError *error);

extern NSString *const kBaseWebAppUrl;

@class Team, Person, Conversation, Injury, CalendarMap;

@interface WebServer : NSObject

+ (instancetype)sharedInstance;

- (void)getMyTeamsWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)getListOfPlayersForTeam:(Team *)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)getFullDetailsWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)getSportsWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)getConversationsAndMessagesWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)getInvitedMembersForTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)getCalendarItemsWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure;

- (void)registerStepOne:(const NSDictionary *const)parameters success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)registerStepTwo:(const NSDictionary *const)parameters success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)ipinfoToLocationWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)createTeam:(const Team *const)parameters success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)addPeople:(const NSDictionary *const)peopleByRole toTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)registerForTeam:(const NSDictionary *const)parameters success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)sendChatText:(const NSString *const)text toPeople:(const NSSet *const)people forConversation:(const Conversation *const)conversation success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)getNewConversationIdentWithName:(NSString *)name people:(const NSSet *const)people success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)updateInjuryStatusForPerson:(const Person *const)person success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)addOrUpdateInjuryStatus:(const Injury *const)injury success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;



- (void)saveCalendarItem:(const EKEvent *const)event forTeam:(const Team *const)team calendarMap:(CalendarMap *)map rebuildString:(BOOL)shouldRebuild success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)saveCalendarItem:(const EKEvent *const)event forTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;

- (void)deleteTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)deleteCalendarItem:(const NSNumber *const)sql_ident success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;
- (void)dropPlayerWithIdent:(const NSNumber *)ident fromTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;

- (void)updatePerson:(const Person *const)person success:(WebResponseSuccess)success failure:(WebResponseFailure)failure;

@end
