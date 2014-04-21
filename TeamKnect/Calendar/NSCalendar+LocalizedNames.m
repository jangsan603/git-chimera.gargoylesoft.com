//
//  NSCalendar+LocalizedNames.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/14/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "NSCalendar+LocalizedNames.h"

@implementation NSCalendar (LocalizedNames)

- (NSArray *)currentLocaleShortWeekdaySymbols {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    NSMutableArray *ret = [NSMutableArray arrayWithArray:[formatter shortWeekdaySymbols]];

    // self.firstWeekday is the day of the week (Sunday, Monday, etc..) that people like to see calendars start on.
    // In the US, for example, that's Sunday, which is always 1.  In the Netherlands, firstWeekday would be 2, as they
    // want to see it start on Monday instead, and have Sunday be the last day shown.
    for (NSInteger numberOfItemsToMove = self.firstWeekday - 2; numberOfItemsToMove >= 0; numberOfItemsToMove--) {
        NSString *name = [ret firstObject];
        [ret removeObjectAtIndex:0];
        [ret addObject:name];
    }

    return ret;
}

- (NSDate *)firstSecondOfFirstDayOfMonthContaining:(NSDate *)date {
    NSDateComponents *components = [self components:NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra fromDate:date];
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;

    return [self dateFromComponents:components];
}

- (NSDate *)lastSecondOfLastDayOfMonthContaining:(NSDate *)date {
    date = [self firstSecondOfFirstDayOfMonthContaining:date];

    NSDateComponents *components = [NSDateComponents new];
    components.month = 1;

    date = [self dateByAddingComponents:components toDate:date options:0];

    components.month = 0;
    components.second = -1;

    return date = [self dateByAddingComponents:components toDate:date options:0];
}

@end
