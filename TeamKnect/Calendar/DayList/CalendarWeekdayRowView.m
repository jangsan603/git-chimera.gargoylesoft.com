//
//  CalendarWeekdayRowView.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/12/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarWeekdayRowView.h"
#import "NSDate+DateWithoutTime.h"

@interface CalendarWeekdayRowView ()
@property (nonatomic, copy) CalendarWeekdayRowBlock onDateSelected;
@property (nonatomic, strong) NSMutableArray *dates;
@property (nonatomic, strong) NSMutableArray *dateButtons;
@property (nonatomic, weak) NSCalendar *calendar;
@end

@implementation CalendarWeekdayRowView

- (instancetype)initWithCalendar:(NSCalendar *)calendar frame:(CGRect)frame buttonFrames:(const NSArray *const)buttonFrames onDateSelected:(CalendarWeekdayRowBlock)onDateSelected {
    if ((self = [super initWithFrame:frame])) {
        self.calendar = calendar;
        self.onDateSelected = onDateSelected;
        
        self.dateButtons = [[NSMutableArray alloc] init];
        
        long i = 0;
        
        for (const NSValue *const value in buttonFrames) {
            UIButton *const button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.backgroundColor = [UIColor clearColor];
            button.frame = [value CGRectValue];
            button.tag = i++;
            
            [button setTitle:[NSString stringWithFormat:@"%ld", i] forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.dateButtons addObject:button];
            
            [self addSubview:button];
            
            // Insert the image view below the button so the numbers display
            UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot_player_number_detail"]];
            iv.translatesAutoresizingMaskIntoConstraints = NO;
            iv.tag = button.tag + 100;
            [self insertSubview:iv belowSubview:button];
            
            iv.center = button.center;
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:iv
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:button
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1 constant:5.]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:iv
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:button
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1 constant:5]];
        }
    }
    
    return self;
}

- (void)configureWeekdayNumbersBasedOnDate:(NSDate *)date {
    date = [date dateWithoutTime];
    
    self.dates = [NSMutableArray new];
    
    _displayDate = [date copy];
    
    NSDateComponents *components = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:date];
    const NSInteger daysPastFirstWeekday = components.weekday - 1;
    
    // Move ourselves to the start of the week, if we're not already there.
    if (daysPastFirstWeekday > 0) {
        NSDateComponents *const prevDayComponent = [[NSDateComponents alloc] init];
        prevDayComponent.day = -daysPastFirstWeekday;
        
        date = [self.calendar dateByAddingComponents:prevDayComponent toDate:date options:0];
    }
    
    // Now add in as many dates as there are in a week.
    NSDateComponents *const oneDay = [[NSDateComponents alloc] init];
    oneDay.day = 1;
    
    for (UIButton *const button in self.dateButtons) {
        [self.dates addObject:date];
        
        components = [self.calendar components:NSDayCalendarUnit fromDate:date];
        [button setTitle:[NSString stringWithFormat:@"%ld", (long)components.day] forState:UIControlStateNormal];
        [button setTitleColor:kTintColor forState:UIControlStateNormal];
        
        UIImageView *iv = (UIImageView *) [self viewWithTag:100 + button.tag];
        iv.hidden = YES;
        
        date = [self.calendar dateByAddingComponents:oneDay toDate:date options:0];
    }
}

- (void)moveByWeeks:(const NSInteger)offset {
    NSDateComponents *components = [NSDateComponents new];
    components.week = offset;
    
    NSDate *newDate = [self.calendar dateByAddingComponents:components toDate:[self.dates firstObject] options:0];
    [self configureWeekdayNumbersBasedOnDate:newDate];
    
    self.displayDate = newDate;
}

- (void)buttonPressed:(const UIButton *const)sender {
    if (self.onDateSelected)
        self.onDateSelected(self.dates[sender.tag]);
}

- (void)setDisplayDate:(NSDate *)date {
    date = [date dateWithoutTime];

//    Don't do this check because we need to call this with same date to force th highlight to appear sometimes.
//    if (self.displayDate == date)
//        return;
    
    // This will set _displayDate.  If you call setDisplayDate then the button images are changed.
    // If you call configureWeekdayNumbersBasedOnDate then button images are cleared.
    [self configureWeekdayNumbersBasedOnDate:date];
    
    for (NSInteger i = self.dateButtons.count - 1; i >= 0; i--) {
        NSDate *buttonDate = self.dates[i];
        
        const UIButton *const button = self.dateButtons[i];
        UIImageView *iv = (UIImageView *) [self viewWithTag:100 + button.tag];
        
        if ([buttonDate compare:date] == NSOrderedSame) {
            iv.hidden = NO;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            iv.hidden = YES;
            [button setTitleColor:kTintColor forState:UIControlStateNormal];
        }
    }
}

- (NSDate *)firstWeekday {
    return [self.dates firstObject];
}

- (NSDate *)lastWeekday {
    return [self.dates lastObject];
}

@end
