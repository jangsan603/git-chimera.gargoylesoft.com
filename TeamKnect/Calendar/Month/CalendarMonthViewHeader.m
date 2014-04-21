//
//  CalendarMonthViewHeader.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/8/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarMonthViewHeader.h"

@interface CalendarMonthViewHeader ()
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@end

@implementation CalendarMonthViewHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = RGB_COLOR(0, 77, 142);
    self.date.textColor = kTintColor;
    
    UIImage *img = [[UIImage imageNamed:@"ic_arrow_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.leftButton setImage:img forState:UIControlStateNormal];
    self.leftButton.tintColor = kTintColor;
    
    img = [[UIImage imageNamed:@"ic_arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.rightButton setImage:img forState:UIControlStateNormal];
    self.rightButton.tintColor = kTintColor;
}

- (IBAction)leftButtonPressed:(id)sender {
    if (self.onMonthChangePressed)
        self.onMonthChangePressed(YES);
}

- (IBAction)rightButtonPressed:(id)sender {
    if (self.onMonthChangePressed)
        self.onMonthChangePressed(NO);
}

@end
