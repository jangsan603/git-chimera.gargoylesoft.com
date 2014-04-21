//
//  GSEventEditorViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/27/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@class Team;

@interface GSEventEditorViewController : UITableViewController

@property (nonatomic, strong) NSDate *initialDate;
@property (nonatomic, strong) EKEvent *event;
@property (nonatomic, strong) Team *team;
@property (nonatomic, assign) EKSpan span;
@property (nonatomic, assign) BOOL isNewlyCreatedEvent;
@property (nonatomic, assign) BOOL changedSomething;
@property (nonatomic, assign) BOOL changedRecurrence;

@end
