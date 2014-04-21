//
//  CalendarWeekdayRowView.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/12/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

typedef void (^CalendarWeekdayRowBlock)(NSDate *date);

@interface CalendarWeekdayRowView : UIView

@property (nonatomic, copy) NSDate *displayDate;

- (instancetype)initWithCalendar:(NSCalendar *)calendar frame:(CGRect)frame buttonFrames:(const NSArray *const)buttonFrames onDateSelected:(CalendarWeekdayRowBlock)onDateSelected;
- (void)configureWeekdayNumbersBasedOnDate:(NSDate *)date;

- (void)moveByWeeks:(const NSInteger)offset;

- (NSDate *)firstWeekday;
- (NSDate *)lastWeekday;

@end
