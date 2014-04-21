//
//  BaseMessageBubbleCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/29/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "BaseMessageBubbleCell.h"

@interface BaseMessageBubbleCell ()
@end

@implementation BaseMessageBubbleCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor orangeColor];

    self.label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.numberOfLines = 0;

    self.label.font = [BaseMessageBubbleCell fontForChatBubbles];

    [self.contentView addSubview:self.label];

    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

    // The UIImageView should extend 5 pixels below the label
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImage
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.label
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1 constant:5]];

    // The label should be 5 pixels below the UIImageView
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.label
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.bubbleImage
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1 constant:5.]];

    self.labelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.label
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:0
                                                            multiplier:1 constant:1.];

    self.labelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.label
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:0
                                                             multiplier:1 constant:1.];

    [self.contentView addConstraints:@[self.labelHeightConstraint, self.labelWidthConstraint]];
}

- (void)setText:(NSString *)text maxBubbleWidth:(CGFloat)maxBubbleWidth {
    self.label.text = text;

    // Find out how big the text label needs to be
    const CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(maxBubbleWidth, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName : self.label.font}
                                                   context:nil];

    self.labelHeightConstraint.constant = ceilf(CGRectGetHeight(boundingRect));
    self.labelWidthConstraint.constant = ceilf(CGRectGetWidth(boundingRect));
}

+ (UIFont *)fontForChatBubbles {
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
