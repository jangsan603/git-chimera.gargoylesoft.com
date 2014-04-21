//
//  NSDate+DateWithoutTime.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/19/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "NSDate+DateWithoutTime.h"

@implementation NSDate (DateWithoutTime)

- (NSDate *)dateWithoutTime {
    const NSCalendar *const calendar = [NSCalendar currentCalendar];
    const NSUInteger wanted = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *const components = [calendar components:wanted fromDate:self];
    components.hour = 12;
    
    return [calendar dateFromComponents:components];
}

+ (NSDate *)dateWithoutTime {
    return [[NSDate date] dateWithoutTime];
}

@end
