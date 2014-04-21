//
//  RightMessageBubbleCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/29/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "RightMessageBubbleCell.h"

@implementation RightMessageBubbleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // The label should be 15 pixels to the right of the UIImageView
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.label
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.bubbleImage
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1 constant:15]];

    // The UIImageView should extend 22 pixels to the right of the label
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImage
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.label
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1 constant:22]];
}

- (void)setText:(NSString *)text maxBubbleWidth:(CGFloat)maxBubbleWidth {
    [super setText:text maxBubbleWidth:maxBubbleWidth];

    self.label.textColor = RGB_COLOR(171., 179., 187.);
}

@end
