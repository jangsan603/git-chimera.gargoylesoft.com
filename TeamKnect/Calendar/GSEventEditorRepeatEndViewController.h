//
//  GSEventEditorRepeatEndViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

typedef void (^GSEventEditorRepeatEndBlock)(NSDate *date);

@interface GSEventEditorRepeatEndViewController : UITableViewController

@property (nonatomic, copy) GSEventEditorRepeatEndBlock onSelection;
@property (nonatomic, strong) NSDate *date;

@end
