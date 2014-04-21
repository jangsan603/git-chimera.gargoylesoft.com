//
//  WebServer.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "WebServer.h"
#import "CalendarMap.h"
#import "CalendarMapExtras.h"
#import "Person+Category.h"
#import "EKEvent+rfc2445.h"
#import "Conversation.h"
#import "Picture.h"
#import "Injury.h"
#import "Sport.h"
#import "Team.h"

NSString *const kBaseWebAppUrl = @"http://www.teamknect.com/";
NSString *const kBaseWebRESTUrl = @"http://www.teamknect.com/";

@interface WebServer ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@end

@implementation WebServer

+ (instancetype)sharedInstance {
    static WebServer *me = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        me = [[WebServer alloc] init];
    });

    return me;
}

- (instancetype)init {
    if ((self = [super init])) {
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseWebRESTUrl]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSOperationQueue *queue = _manager.operationQueue;

        [_manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [queue setSuspended:NO];
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    [queue setSuspended:YES];
                    [BlockAlertView okWithMessage:NSLocalizedString(@"NOT_ONLINE_MSG", @"Message box saying the network is offline")];
                    break;
            }
        }];
    }

    return self;
}

- (void)updatePerson:(const Person *const)person success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    NSString *photo = person.picture ? [person.picture.image base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength] : @"";
    
    const NSDictionary *const parameters = @{
                                             @"person_id" : person.sql_ident,
                                             @"email" : person.email,
                                             @"first" : person.first,
                                             @"last" : person.last,
                                             @"dob" : @([person.dob timeIntervalSince1970]),
                                             @"picture" : photo,
                                             @"address" : person.address,
                                             @"country_of_birth" : person.country_of_birth,
                                             @"height" : person.height,
                                             @"weight" : person.weight,
                                             @"nationality" : person.nationality,
                                             @"phone" : person.phone
                                             };
    
    [self postDataToWeb:@"person/updatePerson" params:parameters success:success failure:failure];
}

#pragma mark - === GET === -

- (void)getDataFromWeb:(NSString *)url lastUpdateTime:(NSTimeInterval)lastUpdateTime success:(WebResponseSuccess)success failure:(WebResponseFailure)failure timeUpdate:(dispatch_block_t)timeUpdate {
    [self.manager GET:url
           parameters:nil    // TODO: Maybe make this take lastUpdateTime and then call {@from body} in the php files??
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if (timeUpdate)
                      timeUpdate();
                  
                  if (success)
                      success(responseObject);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  if (failure)
                      failure(error);
              }];
}

- (void)getMyTeamsWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    NSTimeInterval lastUpdateTime = [[NSDate date] timeIntervalSince1970];

    NSString *url = [NSString stringWithFormat:@"team/%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"me"]];

    [self getDataFromWeb:url lastUpdateTime:lastUpdateTime success:success failure:failure timeUpdate:nil];
}

- (void)getListOfPlayersForTeam:(Team *)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    NSTimeInterval lastUpdateTime = [[NSDate date] timeIntervalSince1970];
    NSString *url = [NSString stringWithFormat:@"team/players/%@/%.0f", team.sql_ident, lastUpdateTime];
    
    [self getDataFromWeb:url lastUpdateTime:lastUpdateTime success:success failure:failure timeUpdate:nil];
}

- (void)getFullDetailsWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self getDataFromWeb:[NSString stringWithFormat:@"team/fullDetailsForPerson/%ld", (long) [[[NSUserDefaults standardUserDefaults] valueForKey:@"me"] longValue]]
          lastUpdateTime:0
                 success:success failure:failure timeUpdate:nil];
}

- (void)ipinfoToLocationWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self getDataFromWeb:@"http://ipinfo.io/geo" lastUpdateTime:0 success:success failure:failure timeUpdate:nil];
}

- (void)getSportsWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self getDataFromWeb:@"sport" lastUpdateTime:0 success:success failure:failure timeUpdate:nil];
}

- (void)getInvitedMembersForTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    NSString *str = [NSString stringWithFormat:@"Team/members/%@", team.sql_ident];
    
    [self getDataFromWeb:str lastUpdateTime:0 success:success failure:failure timeUpdate:nil];
}

- (void)getConversationsAndMessagesWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    __block NSTimeInterval date = [[[NSUserDefaults standardUserDefaults] valueForKey:@"conversationUpdateTime"] doubleValue];

    [self getDataFromWeb:[NSString stringWithFormat:@"chat/conversationsFor/%d/%.0f", 1, date]
          lastUpdateTime:date
                 success:^(id data) {
                     if (date == 0)
                         date = [[NSDate date] timeIntervalSince1970];
                     else
                         date++;

                     //                    [[NSUserDefaults standardUserDefaults] setValue:@(date) forKey:@"conversationUpdateTime"];

                     if (success)
                         success(data);
                 } failure:failure timeUpdate:nil];
}

- (void)getCalendarItemsWithSuccess:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    const NSNumber *const me = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];
    if (me == nil)
        return;
    
    __block NSTimeInterval date = [[[NSUserDefaults standardUserDefaults] valueForKey:@"calendarUpdateTime"] doubleValue];

    [self getDataFromWeb:[NSString stringWithFormat:@"calendar/%@/%.0f", me, date]
          lastUpdateTime:0 success:^(id data) {
              if (date == 0)
                  date = [[NSDate date] timeIntervalSince1970];
              else
                  date++;
              
              //                    [[NSUserDefaults standardUserDefaults] setValue:@(date) forKey:@"calendarUpdateTime"];

              if (success)
                  success(data);
          } failure:failure timeUpdate:nil];
}

#pragma mark - === POST === -

- (void)postDataToWeb:(const NSString *const)url params:(const NSDictionary *const)params success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self.manager POST:(NSString *)url
            parameters:(NSDictionary *)params
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   if (success)
                       success(responseObject);
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   if (failure)
                       failure(error);
                
                   NSLog(@"Web Post: %@", error);
                   
                   if (params) {
                       NSLog(@"\n\nParams: %@\n\npostjson '%@' %@%@", [params debugDescription], [self formattedJSON:params], kBaseWebAppUrl, url);
                   }
               }];
}

- (void)registerStepOne:(const NSDictionary *const)parameters success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self postDataToWeb:@"person/registerStepOne" params:parameters success:success failure:failure];
}

- (void)registerStepTwo:(const NSDictionary *const)parameters success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self postDataToWeb:@"person/registerStepTwo" params:parameters success:success failure:failure];
}

- (void)createTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    const NSDictionary *const parameters = @{
                                             @"name" : team.name,
                                             @"zip" : team.zip,
                                             @"sport" : team.sport.sql_ident
                                             };

    [self postDataToWeb:@"team" params:parameters success:success failure:failure];
}

- (void)addPeople:(const NSDictionary *const)peopleByRole toTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    const NSNumber *const me = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"sql_ident = %@", me];
    request.propertiesToFetch = @[@"last", @"first"];
    
    const Person *const person = [[team.managedObjectContext executeFetchRequest:request error:NULL] firstObject];
    
    // TODO: Make this actually use the role
    NSMutableSet *set = [NSMutableSet set];
    for (NSArray *ary in [peopleByRole allValues])
        [set addObjectsFromArray:ary];
    
    const NSDictionary *const params = @{
                                         @"team_id" : team.sql_ident,
                                         @"people" : [set allObjects],
                                         @"team_name" : team.name,
                                         @"inviter" : [Person formattedNameWithFirst:person.first last:person.last lastFirst:NO]
                                         };

    [self postDataToWeb:@"team/addPeople" params:params success:success failure:failure];
}

- (void)registerForTeam:(const NSDictionary *const)parameters success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self postDataToWeb:@"team/join" params:parameters success:success failure:failure];
}

- (void)getNewConversationIdentWithName:(NSString *)name people:(const NSSet *const)people success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    NSArray *peopleIdents = [[people valueForKey:@"sql_ident"] allObjects];
    [self postDataToWeb:@"chat/generateConversationIdent" params:@{@"name" : name, @"people" : peopleIdents} success:success failure:failure];
}

- (void)sendChatText:(const NSString *const)text toPeople:(const NSSet *const)people forConversation:(const Conversation *const)conversation success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    const NSNumber *const me = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];

    const NSDictionary *const parameters = @{
                                             @"conversation_id" : conversation.sql_ident,
                                             @"text" : text,
                                             @"people" : [[people allObjects] valueForKey:@"sql_ident"],
                                             @"sender" : me
                                             };

    [self postDataToWeb:@"chat" params:parameters success:success failure:failure];
}

- (void)updateInjuryStatusForPerson:(const Person *const)person success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self postDataToWeb:@"person/updateInjuryStatus" params:@{@"person_id" : person.sql_ident, @"status" : person.injury_status} success:success failure:failure];
}

- (void)addOrUpdateInjuryStatus:(Injury *)injury success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    const NSDictionary *const parameters = @{
                                             @"person_id" : injury.person.sql_ident,
                                             @"injury_id" : injury.sql_ident ? injury.sql_ident : @0,
                                             @"status" : injury.status,
                                             @"site" : injury.site,
                                             @"details" : injury.details,
                                             @"doi" : @([injury.doi timeIntervalSince1970]),
                                             @"dor" : @([injury.dor timeIntervalSince1970])
                                             };
    
    [self postDataToWeb:@"person/injuryStatus" params:parameters success:success failure:failure];
}

- (void)saveCalendarItem:(const EKEvent *const)event forTeam:(const Team *const)team calendarMap:(CalendarMap *)map rebuildString:(BOOL)shouldRebuild success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    NSManagedObjectContext *managedObjectContext;

    if (!map) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CalendarMap"];
        request.predicate = [NSPredicate predicateWithFormat:@"eventIdentifier = %@", event.eventIdentifier];
        request.propertiesToFetch = @[@"sql_ident"];
        
        managedObjectContext = team.managedObjectContext;
        map = [[managedObjectContext executeFetchRequest:request error:NULL] firstObject];
        
        if (!map)
            shouldRebuild = NO;
    } else
        managedObjectContext = map.managedObjectContext;
    
    [managedObjectContext performBlockAndWait:^{
        [managedObjectContext save:NULL];
    }];
    
    NSString *rfcString;
    if (shouldRebuild) {
        NSMutableString *str = [NSMutableString stringWithFormat:@"BEGIN:VEVENT\r\n%@", [event toRfc2445WithUID:map.uid]];
        
        if (map.exclusions)
            [str appendString:map.exclusions];
        
        [str appendString:@"\r\nEND:VEVENT"];
        
        for (CalendarMapExtras *extra in [map.extras allObjects])
            [str appendFormat:@"\r\nBEGIN:VEVENT\r\n%@\r\nEND:VEVENT", extra.rfc2445];
        
        rfcString = str;
    } else if (map) {
        if (map.rfc2445 == nil) {
            [BlockAlertView okWithMessage:@"Failed to save calendar item with no data."];
            return;
        }
        
        rfcString = [NSString stringWithFormat:@"BEGIN:VEVENT\r\n%@\r\nEND:VEVENT", map.rfc2445];
    } else {
        // If this one is called, then it means it's a newly created event.
        NSString *data = [event toRfc2445];
        if (data == nil) {
            [BlockAlertView okWithMessage:@"Failed to save calendar item with no data."];
            return;
        }
        
        rfcString = [NSString stringWithFormat:@"BEGIN:VEVENT\r\n%@\r\nEND:VEVENT", data];
    }
    
    const NSDictionary *const parameters = @{
                                             @"sql_ident" : map ? map.sql_ident : @0,
                                             @"team_id" : team.sql_ident,
                                             @"rfc2445" : rfcString
                                             };
    
    [self postDataToWeb:@"calendar" params:parameters success:^(id data) {
        NSNumber *num = [data firstObject];
        if (num)
            [managedObjectContext performBlock:^{
                // This was a new event, so make the linkage
                CalendarMap *entity = [NSEntityDescription insertNewObjectForEntityForName:@"CalendarMap" inManagedObjectContext:managedObjectContext];
                entity.sql_ident = num;
                entity.eventIdentifier = event.eventIdentifier;
                entity.uid = [EKEvent uid];
                entity.rfc2445 = [event toRfc2445WithUID:entity.uid];
                entity.team = (Team *) team;
                [managedObjectContext save:NULL];
            }];
        
        if (success)
            success(data);
    } failure:failure];
}

- (void)saveCalendarItem:(const EKEvent *const)event forTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self saveCalendarItem:event forTeam:team calendarMap:nil rebuildString:NO success:success failure:failure];
}

#pragma mark - === Deletes === -

- (NSString *)formattedJSON:(const NSDictionary *const)params {
    if (params) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:NULL];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else
        return @"{}";
}

- (void)deleteDataFromWeb:(const NSString *const)url params:(const NSDictionary *const)params success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self.manager DELETE:(NSString *)url parameters:(NSDictionary *)params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
        
        NSLog(@"WEB DELETE: curl -X DELETE %@%@/%@:  %@", [self formattedJSON:params], [self.manager.baseURL absoluteString], url, error);
    }];
}


- (void)deleteCalendarItem:(const NSNumber *const)sql_ident success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self deleteDataFromWeb:[NSString stringWithFormat:@"calendar/%@", sql_ident] params:nil success:success failure:failure];
}

- (void)dropPlayerWithIdent:(const NSNumber *)ident fromTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self deleteDataFromWeb:@"team/player" params:@{@"ident" : ident, @"team" : team.sql_ident} success:success failure:failure];
}

- (void)deleteTeam:(const Team *const)team success:(WebResponseSuccess)success failure:(WebResponseFailure)failure {
    [self deleteDataFromWeb:[NSString stringWithFormat:@"team/%@", team.sql_ident] params:nil success:success failure:failure];
}
@end
