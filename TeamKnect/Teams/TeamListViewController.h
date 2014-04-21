//
//  TeamListViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 12/25/13.
//  Copyright (c) 2013 Gargoyle Software, LLC. All rights reserved.
//

@class Team;

@interface TeamListViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Team *team;

@end
