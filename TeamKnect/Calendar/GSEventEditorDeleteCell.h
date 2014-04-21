//
//  GSEventEditorDeleteCell.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

typedef void (^GSEventEditorDeleteBlock)(CGRect frame);

@interface GSEventEditorDeleteCell : UITableViewCell

@property (nonatomic, copy) GSEventEditorDeleteBlock onDeleteButtonPressed;

@end
