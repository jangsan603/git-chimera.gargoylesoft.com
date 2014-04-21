//
//  GSEventEditorAllDayCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSEventEditorAllDayCell.h"

@interface GSEventEditorAllDayCell ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation GSEventEditorAllDayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.label.text = NSLocalizedString(@"CALENDAR_EDIT_ALL_DAY", @"Label for the row saying the event is all day long");
}

- (IBAction)onToggle:(id)sender {
    if (self.onToggle)
        self.onToggle(self.toggle.on);
}

@end
