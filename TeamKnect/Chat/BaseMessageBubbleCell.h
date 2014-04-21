//
//  BaseMessageBubbleCell.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/29/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseMessageBubbleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bubbleImage;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSLayoutConstraint *labelWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *labelHeightConstraint;

- (void)setText:(NSString *)text maxBubbleWidth:(CGFloat)maxBubbleWidth;

+ (UIFont *)fontForChatBubbles;

@end
