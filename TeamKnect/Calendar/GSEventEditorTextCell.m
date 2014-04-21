//
//  GSEventEditorTextCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/27/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSEventEditorTextCell.h"

@implementation GSEventEditorTextCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.text.borderStyle = UITextBorderStyleNone;
}

@end
