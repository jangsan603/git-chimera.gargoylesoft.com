//
//  GSEventEditorDeleteCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSEventEditorDeleteCell.h"

@interface GSEventEditorDeleteCell ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@end

@implementation GSEventEditorDeleteCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.button.backgroundColor = [UIColor clearColor];
    [self.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.button setTitle:NSLocalizedString(@"DELETE_CALENDAR_EVENT", @"Text for button which deletes the currently edited calendar event.") forState:UIControlStateNormal];
}

- (IBAction)onDeleteButtonPressed:(UIButton *)sender {
    if (self.onDeleteButtonPressed)
        self.onDeleteButtonPressed(sender.frame);
}

@end
