//
//  GSEventEditorDatePickerCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/27/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSEventEditorDatePickerCell.h"

@implementation GSEventEditorDatePickerCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.picker.minuteInterval = 15;
}

@end
