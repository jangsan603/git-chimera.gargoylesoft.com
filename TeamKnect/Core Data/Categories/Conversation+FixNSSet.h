//
//  Conversation+FixNSSet.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/9/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "Conversation.h"

/**
 @category Conversation (FixNSSet)
 @discussion Extra methods to be used for a @c Conversation object.
 */
@interface Conversation (FixNSSet)

/**
 Grabs all the new @c Conversation and @c Message objects from the webserver and @c saves them to the indicated @c parentContext.
 @param parentContext The @c NSManagedObjectContext which will be populated.
 @param onSuccess A block to be called when the data is successfully imported.
 @param onNoNewData A block to be called when the webserver said there was nothing new to load.
 @param onFailure A block to be called when something went wrong.
 @remarks All of the block methods will be called on the main thread.
 */
+ (void)loadConversationsWithParentContext:(NSManagedObjectContext *)parentContext onSuccess:(dispatch_block_t)onSuccess onNoNewData:(dispatch_block_t)onNoNewData onFailure:(WebResponseFailure)onFailure;

- (NSString *)formattedNameExcluding:(const NSNumber *const)me;

@end
