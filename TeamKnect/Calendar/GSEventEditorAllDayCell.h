//
//  GSEventEditorAllDayCell.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

typedef void (^GSEventEditorToggleBlock)(BOOL isOn);

@interface GSEventEditorAllDayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *toggle;

@property (nonatomic, copy) GSEventEditorToggleBlock onToggle;
@end
