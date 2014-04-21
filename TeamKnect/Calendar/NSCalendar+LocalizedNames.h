//
//  NSCalendar+LocalizedNames.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/14/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (LocalizedNames)

- (NSArray *)currentLocaleShortWeekdaySymbols;
- (NSDate *)firstSecondOfFirstDayOfMonthContaining:(NSDate *)date;
- (NSDate *)lastSecondOfLastDayOfMonthContaining:(NSDate *)date;

@end
