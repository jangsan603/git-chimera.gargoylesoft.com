//
//  GSEventEditorRepeatViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@interface GSEventEditorRepeatViewController : UITableViewController

@property (nonatomic, assign) EKRecurrenceFrequency frequency;
@property (nonatomic, assign) NSInteger interval;
@property (nonatomic, assign) BOOL recurring;
@property (nonatomic, copy) NSString *text;
 
@end
