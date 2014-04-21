//
//  ConversationTargetsViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/8/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@interface ConversationTargetsViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (NSSet *)selectedPeople NS_RETURNS_RETAINED;
- (NSString *)conversationName;

@end
