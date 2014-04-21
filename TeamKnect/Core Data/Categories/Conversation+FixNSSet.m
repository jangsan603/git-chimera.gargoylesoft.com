//
//  Conversation+FixNSSet.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/9/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "Conversation+FixNSSet.h"
#import "NSManagedObjectContext+CoreDataImport.h"
#import "Person+Category.h"
#import "Message.h"

@implementation Conversation (FixNSSet)

- (void)addMessagesObject:(Message *)value {
    NSMutableOrderedSet *set = [self mutableOrderedSetValueForKey:@"messages"];
    [set addObject:value];
}

- (NSString *)formattedNameExcluding:(const NSNumber *const)me {
    if (self.name)
        return self.name;

    for (const Person *const person in self.people)
        if (![me isEqualToNumber:person.sql_ident])
            return [person formattedName];

    return nil;
}

+ (void)loadConversationsWithParentContext:(NSManagedObjectContext *)parentContext onSuccess:(dispatch_block_t)onSuccess onNoNewData:(dispatch_block_t)onNoNewData onFailure:(WebResponseFailure)onFailure {
    [[WebServer sharedInstance] getConversationsAndMessagesWithSuccess:^(const NSArray *const data) {
        if (data.count == 0) {
            if (onNoNewData)
                onNoNewData();
            return;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            importContext.parentContext = parentContext;
            importContext.undoManager = nil;

            [importContext performBlockAndWait:^{
                NSDictionary *conversations = [importContext updateOrInsert:data[0] entityName:@"Conversation" dateFormat:@"%Y-%m-%d %T"];

                for (const NSDictionary *const dict in data[0]) {
                    NSFetchRequest *const request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
                    request.predicate = [NSPredicate predicateWithFormat:@"sql_ident IN %@", dict[@"people_ids"]];

                    Conversation *conversation = conversations[@([dict[@"sql_ident"] longValue])];
                    conversation.people = [NSSet setWithArray:[importContext executeFetchRequest:request error:NULL]];
                }

                if ([data[1] isKindOfClass:[NSArray class]]) {
                    // If data[1] is an array, that means there were no messages as the JSON comes back as an empty array instead of
                    // as an empty hash.
                    if (onSuccess)
                        onSuccess();
                    
                    return;
                }

                [(NSDictionary *)data[1] enumerateKeysAndObjectsUsingBlock:^(const NSString *const key, const NSArray *const obj, BOOL *stop) {
                    Conversation *conversation = conversations[@((long)[key longLongValue])];

                    const NSDictionary *const messages = [importContext updateOrInsert:obj entityName:@"Message" dateFormat:@"%Y-%m-%d %T"];
                    for (Message *message in [messages allValues])
                        message.conversation = conversation;

                    for (const NSDictionary *const dict in obj) {
                        NSNumber *personSqlIdent = @([dict[@"sender_id"] longValue]);

                        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
                        request.predicate = [NSPredicate predicateWithFormat:@"sql_ident = %@", personSqlIdent];

                        const NSArray *const ary = [importContext executeFetchRequest:request error:NULL];

                        NSNumber *messageSqlIdent = @([dict[@"sql_ident"] longValue]);
                        Message *message = messages[messageSqlIdent];
                        message.sender = [ary firstObject];
                    }
                }];

                NSError *error = nil;
                if (![importContext save:&error]) {
                    NSLog(@"%s: %@", __func__, error);
                    if (onFailure)
                        dispatch_async(dispatch_get_main_queue(), ^{
                            onFailure(error);
                        });

                    return;
                }

                [parentContext performBlockAndWait:^{
                    NSError *e2;
                    if (![parentContext save:&e2]) {
                        NSLog(@"2) %s: %@", __func__, e2);
                        if (onFailure)
                            dispatch_async(dispatch_get_main_queue(), ^{
                                onFailure(error);
                            });

                        return;
                    }
                }];

                if (onSuccess)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        onSuccess();
                    });
            }];
        });
    } failure:onFailure];
}

@end
