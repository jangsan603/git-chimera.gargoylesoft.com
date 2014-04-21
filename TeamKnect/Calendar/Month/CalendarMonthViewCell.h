//
//  CalendarMonthViewCell.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/14/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarMonthViewCell : UICollectionViewCell

- (void)setDayIsSelected:(BOOL)selected;

- (void)setDayNumber:(NSInteger)dayNumber dotColor:(UIColor *)dotColor textColor:(UIColor *)textColor;

@end
