//
//  CalendarMonthViewCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/14/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarMonthViewCell.h"

@interface CalendarMonthViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dot;
@property (weak, nonatomic) IBOutlet UIImageView *daySelectedImage;
@property (nonatomic, strong) CALayer *topBorder;
@property (nonatomic, strong) NSDate *date;
@end

@implementation CalendarMonthViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.dateLabel.textAlignment = NSTextAlignmentCenter;

    self.dot.image = [[UIImage imageNamed:@"dot_calendar_tintable"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.daySelectedImage.image = [UIImage imageNamed:@"dot_player_number_detail"];

    self.topBorder = [CALayer layer];
    self.topBorder.borderWidth = 1.;
    self.topBorder.borderColor = kTintColor.CGColor;
    self.topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.);
    [self.layer addSublayer:self.topBorder];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.daySelectedImage
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1 constant:10.]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.daySelectedImage
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.daySelectedImage
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1 constant:0]];
}

- (void)setDayIsSelected:(BOOL)selected {
    if (selected) {
        self.daySelectedImage.hidden = NO;
        self.dateLabel.textColor = [UIColor whiteColor];
    } else {
        self.daySelectedImage.hidden = YES;
    }
}

- (void)setDayNumber:(NSInteger)dayNumber dotColor:(UIColor *)dotColor textColor:(UIColor *)textColor {
    self.dateLabel.text = [NSString stringWithFormat:@"%ld", (long) dayNumber];
    self.dateLabel.textColor = textColor;
    self.dot.tintColor = dotColor;
}

@end
