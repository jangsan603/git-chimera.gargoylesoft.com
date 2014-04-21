//
//  NSDate+DebugStrings.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "NSDate+DebugStrings.h"

@implementation NSDate (DebugStrings)

- (NSString *)justDate {
    return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];


}

- (NSString *)dateAndTime {
    return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)dateAndTime:(NSString *const)timeZoneName {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:timeZoneName];
    if (formatter.timeZone == nil) {
        NSLog(@"Bad tz name '%@'.  Going to America/Los_Angeles", timeZoneName);
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Los_Angeles"];
    }
    
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    return [formatter stringFromDate:self];
}

@end
