//
//  CalendarMap+Category.m
//  TeamKnect
//
//  Created by Scott Grosch on 4/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarMap+Category.h"
#import "CalendarMapExtras.h"
#import "EKEvent+rfc2445.h"
#import "AppDelegate.h"

@implementation CalendarMap (Category)

- (void)addExceptionDate:(const EKEvent *const)event {
    NSMutableString *str = self.exclusions ? [self.exclusions mutableCopy] : [NSMutableString new];
    [str appendString:@"\r\nEXDATE"];
    
    if (event.allDay) {
        NSDateFormatter *formatter = [EKEvent dateOnlyFormatter];
        [str appendFormat:@";VALUE=DATE:%@", [formatter stringFromDate:event.startDate]];
    } else {
        NSDateFormatter *formatter = [EKEvent dateAndTimeFormatter];
        [str appendFormat:@":%@", [formatter stringFromDate:event.startDate]];
    }

    self.exclusions = str;
}

@end
