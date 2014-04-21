//
//  SettingsViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/22/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy) dispatch_block_t onTeamCreatePressed;

@end
