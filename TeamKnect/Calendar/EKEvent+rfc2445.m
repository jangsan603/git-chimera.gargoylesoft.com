//
//  EKEvent+rfc2445.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/4/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

// http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html

// Creating Recurring Events - iOS Developer Library
//  https://developer.apple.com/library/ios/documentation/DataManagement/Conceptual/EventKitProgGuide/CreatingRecurringEvents/CreatingRecurringEvents.html#//apple_ref/doc/uid/TP40009765-CH3-SW1

#import "EKEvent+rfc2445.h"
#import "NSDate+DateWithoutTime.h"
#include <arpa/inet.h>
#include <uuid/uuid.h>
#include <ifaddrs.h>

@implementation RFC2445
@end

@implementation EKEvent (rfc2445)

#pragma mark - === Date Formatting === -

+ (NSDateFormatter *)dateAndTimeFormatter {
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
    dateTimeFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateTimeFormatter.dateFormat = @"yyyyMMdd'T'HHmmss'Z'";
    
    return dateTimeFormatter;
}

+ (NSDateFormatter *)dateOnlyFormatter {
    // Dates don't deal with timezones, they're just a floating entire day, so don't set a timeZone on the formatter here.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    
    return dateFormatter;
}

#pragma mark - === Event Import === -

+ (RFC2445 *)initRfc2445:(const NSString *const)str {
    // Unfold the lines, then break it apart
    NSArray *lines = [[str stringByReplacingOccurrencesOfString:@"\r\n " withString:@""] componentsSeparatedByString:@"\r\n"];
    
    BOOL startHasTime = NO, endHasTime = NO, foundStart = NO, foundEnd = NO;
    
    RFC2445 *rfc = [RFC2445 new];
    
    NSMutableArray *exclusions = [NSMutableArray new];
    
    for (NSString *line in lines) {
        if ([line hasPrefix:@"DTSTART:"] || [line hasPrefix:@"DTSTART;"]) {
            if ((rfc.startDate = [[self class] dateFromString:line hasTimeComponent:&startHasTime]) == nil)
                return nil;
            foundStart = YES;
        } else if ([line hasPrefix:@"DTEND:"] || [line hasPrefix:@"DTEND;"]) {
            if ((rfc.endDate = [self dateFromString:line hasTimeComponent:&endHasTime]) == nil)
                return nil;
            foundEnd = YES;
        } else if ([line hasPrefix:@"SUMMARY:"]) {
            if (line.length > 8)
                rfc.summary = [[self class] unescapeText:[line substringFromIndex:8]];
        } else if ([line hasPrefix:@"DESCRIPTION:"]) {
            if (line.length > 12)
                rfc.notes = [[self class] unescapeText:[line substringFromIndex:12]];
        } else if ([line hasPrefix:@"LOCATION:"]) {
            if (line.length > 9)
                rfc.location = [self unescapeText:[line substringFromIndex:9]];
        } else if ([line hasPrefix:@"RRULE:"]) {
            if ((rfc.recurrenceRule = [self allocParsedRecurrence:line]) == nil)
                return nil;
        } else if (exclusions && ([line hasPrefix:@"EXDATE:"] || [line hasPrefix:@"EXDATE;"])) {
            NSDate *exclusion = [self dateFromString:line hasTimeComponent:nil];
            if (exclusion)
                [exclusions addObject:exclusion];
        }
    }
    
    rfc.exclusions = exclusions;
    
    // TODO: This has to handle the EXDATE rules and delete them once they've been imported.
    
    if (!foundStart)
        return nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    if (!(startHasTime || endHasTime)) {
        rfc.allDay = YES;
    } else if (!foundEnd) {
        if (startHasTime) {
            // For cases where a "VEVENT" calendar component specifies a "DTSTART" property with a DATE-TIME
            // data type but no "DTEND" property, the event ends on the same calendar date and time of day
            // specified by the "DTSTART" property.
            rfc.endDate = rfc.startDate;
        } else {
            // For cases where a "VEVENT" calendar component specifies a "DTSTART" property with a DATE
            // data type but no "DTEND" property, the events non-inclusive end is the end of the calendar
            // date specified by the "DTSTART" property.
            
            NSDateComponents *components = [calendar components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:rfc.startDate];
            components.hour = 23;
            components.minute = 59;
            components.second = 59;
            
            rfc.endDate = [calendar dateFromComponents:components];
        }
    }
    
    return rfc;
}

- (void)populateFromRfc2445:(const RFC2445 *const)rfc2445 {
    if (rfc2445.recurrenceRule)
        self.recurrenceRules = @[rfc2445.recurrenceRule];

    self.startDate = rfc2445.startDate;
    self.endDate = rfc2445.endDate;
    self.title = rfc2445.summary;
    self.notes = rfc2445.notes;
    self.location = rfc2445.location;
    self.allDay = rfc2445.allDay;
}

- (NSString *)populateFromRfc2445string:(const NSString *const)str exclusions:(NSArray __strong **)exclusions {
    RFC2445 *rfc = [[self class] initRfc2445:str];
    if (!rfc)
        return nil;
    
    [self populateFromRfc2445:rfc];
    
    // TODO:  This should set *exclusions to nil to mutable array
    if (exclusions)
        *exclusions = rfc.exclusions;
    
    return rfc.uid;
}

+ (NSString *)unescapeText:(const NSString *const)text {
    // http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html#4.3.11
    NSString *ret = [text stringByReplacingOccurrencesOfString:@"\\;" withString:@";"];
    ret = [ret stringByReplacingOccurrencesOfString:@"\\," withString:@","];
    return [ret stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
}

+ (NSDate *)dateFromString:(const NSString *const)str hasTimeComponent:(BOOL *)hasTimeComponent {
    int year, month, day, hour, minutes, seconds;
    
    NSCharacterSet *delim = [NSCharacterSet characterSetWithCharactersInString:@";:"];
    NSArray *params = [str componentsSeparatedByCharactersInSet:delim];
    
    NSString *dateStr = nil;
    
    NSMutableDictionary *options = [NSMutableDictionary new];
    
    for (NSInteger i = params.count - 1; i > 0; i--) {
        NSArray *keyValuePair = [params[i] componentsSeparatedByString:@"="];
        if (keyValuePair.count == 1)
            // This is the date
            dateStr = keyValuePair[0];
        else
            options[keyValuePair[0]] = keyValuePair[1];
    }
    
    if (!dateStr && options.count == 0)
        dateStr = (NSString *)str;
    
    NSDateComponents *components = [NSDateComponents new];
    
    if (options[@"TZID"]) {
        NSString *tzid = options[@"TZID"];
        
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:tzid];
        if (tz)
            components.timeZone = tz;
        else
            NSLog(@"Unrecognized timezone '%@'", tzid);
    }
    
    
    const char *const scanStr = [dateStr UTF8String];
    
    const BOOL needsTime = (options[@"VALUE"] && ![options[@"VALUE"] isEqualToString:@"DATE"]) || !options[@"VALUE"];
    if (needsTime) {
        if ([dateStr characterAtIndex:dateStr.length - 1] == 'Z')
            components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        
        if (sscanf(scanStr, "%4d%2d%2dT%2d%2d%2d", &year, &month, &day, &hour, &minutes, &seconds) == 6) {
            components.year = year;
            components.month = month;
            components.day = day;
            components.hour = hour;
            components.minute = minutes;
            components.second = seconds;
            
            if (hasTimeComponent)
                *hasTimeComponent = YES;
            
            return [[NSCalendar currentCalendar] dateFromComponents:components];
        }
        
        return nil;
    } else if (!needsTime && sscanf(scanStr, "%4d%2d%2d", &year, &month, &day) == 3) {
        components.year = year;
        components.month = month;
        components.day = day;
        
        if (hasTimeComponent)
            *hasTimeComponent = NO;
        
        return [[NSCalendar currentCalendar] dateFromComponents:components];
    } else {
        NSLog(@"'%@' has needsTime=%d and time str = '%@'", str, needsTime, dateStr);
        
        return nil;
    }
}

+ (NSArray *)arrayForByValues:(const NSString *const)value constrain:(const int)constraint {
    NSMutableArray *ret = [NSMutableArray new];
    
    int num;
    
    for (NSString *dayNum in [value componentsSeparatedByString:@","]) {
        num = [dayNum intValue];
        if (abs(num) < constraint)
            [ret addObject:@(num)];
    }
    
    return [NSArray arrayWithArray:ret];
}

// http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html#4.3.10
+ (EKRecurrenceRule *)allocParsedRecurrence:(const NSString *const)str {
    // Make sure it's not just the RRULE: part
    if (str.length == 6)
        return nil;
    
    BOOL foundFrequency = NO;
    BOOL foundUntilOrCount = NO;
    
    EKRecurrenceFrequency frequency;
    NSInteger interval = 1, count = 0;
    NSDate *endDate;
    NSMutableArray *daysOfTheWeek;
    NSArray *daysOfTheMonth, *monthsOfTheYear, *weeksOfTheYear, *daysOfTheYear, *positions;
    
    for (NSString *part in [[str substringFromIndex:6] componentsSeparatedByString:@";"]) {
        NSArray *keyValue = [part componentsSeparatedByString:@"="];
        if (keyValue.count != 2)
            return nil;
        
        const NSString *const key = keyValue[0];
        const NSString *const value = keyValue[1];
        
        if ([key isEqualToString:@"FREQ"]) {
            if ([value isEqualToString:@"DAILY"])
                frequency = EKRecurrenceFrequencyDaily;
            else if ([value isEqualToString:@"MONTHLY"])
                frequency = EKRecurrenceFrequencyMonthly;
            else if ([value isEqualToString:@"WEEKLY"])
                frequency = EKRecurrenceFrequencyWeekly;
            else if ([value isEqualToString:@"YEARLY"])
                frequency = EKRecurrenceFrequencyYearly;
            else
                return nil;
            
            foundFrequency = YES;
        } else if ([key isEqualToString:@"INTERVAL"]) {
            interval = [value integerValue];
        } else if ([key isEqualToString:@"UNTIL"]) {
            if (foundUntilOrCount)
                return nil;
            
            foundUntilOrCount = YES;
            
            // Remember that the date parser expects to find a label and :, so fake the colon.
            endDate = [self dateFromString:value hasTimeComponent:NULL];
            if (endDate == nil) {
                // the UNITL keyword is allowed to be just a date, without the VALUE=DATE specifier....sigh.
                int year, month, day;
                if (sscanf([value UTF8String], "%4d%2d%2d", &year, &month, &day) == 3) {
                    NSDateComponents *comps = [NSDateComponents new];
                    comps.year = year;
                    comps.month = month;
                    comps.day = day;
                    
                    // This is bad, because we don't know the timezone....but it's probably the same for teams.
                    // Unless they live on the border of a timezone....
                    endDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
                }
            }
            
            if (!endDate)
                return nil;
        } else if ([key isEqualToString:@"COUNT"]) {
            if (foundUntilOrCount)
                return nil;
            
            foundUntilOrCount = YES;
            
            count = [value integerValue];
        } else if ([key isEqualToString:@"BYDAY"]) {
            daysOfTheWeek = [NSMutableArray new];
            
            // Docs say that 1 is always Sunday for dayOfWeek:weekNumber:
            const NSArray *const daysOfTheWeekValidValues = @[@"SU", @"MO", @"TU", @"WE", @"TH", @"FR", @"SA"];
            
            for (NSString *day in [value componentsSeparatedByString:@","]) {
                NSString *dayStr;
                NSInteger num = 0;
                
                if (day.length > 2) {
                    dayStr = [day substringFromIndex:day.length - 2];
                    num = [[day substringToIndex:day.length - 2] integerValue];
                } else
                    dayStr = day;
                
                const NSUInteger idx = [daysOfTheWeekValidValues indexOfObject:dayStr];
                if (idx == NSNotFound)
                    continue;
                
                // idx is 0-based, but the recurrence week wants it to be 1-based.
                [daysOfTheWeek addObject:[EKRecurrenceDayOfWeek dayOfWeek:idx + 1 weekNumber:num]];
            }
        } else if ([key isEqualToString:@"BYMONTHDAY"])
            daysOfTheMonth = [EKEvent arrayForByValues:value constrain:32];
        else if ([key isEqualToString:@"BYYEARDAY"])
            // This should really be 367 as we want to allow -366 to 366
            daysOfTheYear = [EKEvent arrayForByValues:value constrain:367];
        else if ([key isEqualToString:@"BYWEEKNO"])
            // We really do want -53 to 53, so 54 is the right number.
            weeksOfTheYear = [EKEvent arrayForByValues:value constrain:54];
        else if ([key isEqualToString:@"BYMONTH"])
            monthsOfTheYear = [EKEvent arrayForByValues:value constrain:13];
        else if ([key isEqualToString:@"BYSETPOS"])
            positions = [EKEvent arrayForByValues:value constrain:367];
        
        // TODO: Could set CATEGORIES to be the event type, and store it in CalendarMap, removing the need for a notes field on it.
    }
    
    if (!foundFrequency)
        return nil;
    
    EKRecurrenceEnd *end = nil;
    if (endDate)
        end = [EKRecurrenceEnd recurrenceEndWithEndDate:endDate];
    else if (count)
        end = [EKRecurrenceEnd recurrenceEndWithOccurrenceCount:count];
    
    EKRecurrenceRule *rule;
    if (daysOfTheWeek || daysOfTheMonth || monthsOfTheYear || weeksOfTheYear || daysOfTheYear || positions)
        rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency interval:interval daysOfTheWeek:daysOfTheWeek daysOfTheMonth:daysOfTheMonth monthsOfTheYear:monthsOfTheYear weeksOfTheYear:weeksOfTheYear daysOfTheYear:daysOfTheYear setPositions:positions end:end];
    else
        rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency interval:interval end:end];
    
    return rule;
}

#pragma mark - === Event Export === -

- (NSString *)toRfc2445WithUID:(const NSString *const)uid {
    NSMutableArray *parts = [NSMutableArray new];
    
    @autoreleasepool {
        NSDateFormatter *dateTimeFormatter = [EKEvent dateAndTimeFormatter];
        NSDateFormatter *dateFormatter = [EKEvent dateOnlyFormatter];

        [parts addObject:[NSString stringWithFormat:@"UID:%@", uid]];
        
        // Remember this is the date-time that that iCalendar object representation was created, *not* when the event was created.
        [parts addObject:[NSString stringWithFormat:@"DTSTAMP:%@", [dateTimeFormatter stringFromDate:[NSDate date]]]];
        
        [parts addObject:[NSString stringWithFormat:@"CREATED:%@", [dateTimeFormatter stringFromDate:self.creationDate]]];
        
        switch (self.availability) {
            case EKEventAvailabilityBusy:
            case EKEventAvailabilityUnavailable:
                [parts addObject:[NSString stringWithFormat:@"TRANSP:OPAQUE"]];
                break;
                
            case EKEventAvailabilityFree:
                [parts addObject:[NSString stringWithFormat:@"TRANSP:TRANSPARENT"]];
                
            default:
                break;
        }
        
        if (self.allDay) {
            [parts addObject:[NSString stringWithFormat:@"DTSTART;VALUE=DATE:%@", [dateFormatter stringFromDate:self.startDate]]];
            [parts addObject:[NSString stringWithFormat:@"DTEND;VALUE=DATE:%@", [dateFormatter stringFromDate:self.endDate]]];
        } else {
            [parts addObject:[NSString stringWithFormat:@"DTSTART:%@", [dateTimeFormatter stringFromDate:self.startDate]]];
            [parts addObject:[NSString stringWithFormat:@"DTEND:%@", [dateTimeFormatter stringFromDate:self.endDate]]];
        }
        
        if (self.title.length)
            [parts addObject:[NSString stringWithFormat:@"SUMMARY:%@", [self escapeText:self.title]]];
        
        if (self.notes.length)
            [parts addObject:[NSString stringWithFormat:@"DESCRIPTION:%@", [self escapeText:self.notes]]];
        
        if (self.location.length)
            [parts addObject:[NSString stringWithFormat:@"LOCATION:%@", [self escapeText:self.location]]];
        
        if (self.hasRecurrenceRules)
            [parts addObject:[self rrule:self.allDay ? dateFormatter : dateTimeFormatter]];
    }
    
    [parts enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        parts[idx] = [self foldLine:obj];
    }];
    
    return [parts componentsJoinedByString:@"\r\n"];
}

- (NSString *)toRfc2445 {
    return [self toRfc2445WithUID:[EKEvent uid]];
}

- (NSString *)escapeText:(const NSString *const)text {
    // http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html#4.3.11
    NSString *ret = [text stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    ret = [ret stringByReplacingOccurrencesOfString:@";" withString:@"\\;"];
    return [ret stringByReplacingOccurrencesOfString:@"," withString:@"\\,"];
}

// Spec says that lines should not be longer than 75, excluding the line break.
- (NSString *)foldLine:(NSString *)str {
    if (str.length < 76)
        return str;
    
    NSRange range = NSMakeRange(0, 75);
    NSMutableString *ret = [[NSMutableString alloc] init];
    NSMutableString *line = [[NSMutableString alloc] initWithString:str];
    while (line.length > 75) {
        [ret appendFormat:@"%@\r\n", [line substringToIndex:75]];
        [line replaceCharactersInRange:range withString:@" "];
    }
    
    return [NSString stringWithString:ret];
}

- (NSString *)rrule:(const NSDateFormatter *const)formatter {
    if (!self.hasRecurrenceRules)
        return nil;
    
    EKRecurrenceRule *rule = [self.recurrenceRules firstObject];
    
    NSMutableString *ret = [[NSMutableString alloc] initWithString:@"RRULE:"];
    
    if (rule.frequency == EKRecurrenceFrequencyDaily)
        [ret appendFormat:@"FREQ=DAILY"];
    else if (rule.frequency == EKRecurrenceFrequencyMonthly)
        [ret appendFormat:@"FREQ=MONTHLY"];
    else if (rule.frequency == EKRecurrenceFrequencyWeekly)
        [ret appendFormat:@"FREQ=WEEKLY"];
    else
        [ret appendFormat:@"FREQ=YEARLY"];
    
    if (rule.interval > 1)
        [ret appendFormat:@";INTERVAL=%ld", (long)rule.interval];
    
    const EKRecurrenceEnd *const end = rule.recurrenceEnd;
    if (end == nil) {
        // Never ends
    } else if (end.endDate) {
        [ret appendFormat:@";UNTIL=%@", [formatter stringFromDate:end.endDate]];  
    } else
        [ret appendFormat:@";COUNT=%lu", (unsigned long)end.occurrenceCount];
    
    return [NSString stringWithString:ret];
}

+ (NSString *)uid {
    char buf[INET6_ADDRSTRLEN];
    buf[0] = '\0';
    
    struct ifaddrs *interfaces;
    if (getifaddrs(&interfaces) == 0) {
        for (struct ifaddrs *addr = interfaces; addr != NULL; addr = addr->ifa_next) {
            // en0 = WIFI, pdp_ip0 = Cellular
            if (strncmp(addr->ifa_name, "en", 2) && strncmp(addr->ifa_name, "pdp_ip", 6))
                continue;
            
            if (addr->ifa_addr->sa_family == AF_INET) {
                strcpy(buf, inet_ntoa(((struct sockaddr_in *)addr->ifa_addr)->sin_addr));
                break;
            } else if (addr->ifa_addr->sa_family == AF_INET6) {
                struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *) addr->ifa_addr;
                if (inet_ntop(AF_INET6, &ipv6->sin6_addr, buf, sizeof(buf)) != NULL)
                    break;
            }
        }
        
        freeifaddrs(interfaces);
    }
    
    uuid_t uuid;
    uuid_generate_random(uuid);
    
    uuid_string_t uuidStr;
    uuid_unparse_upper(uuid, uuidStr);
    
    if (buf[0] != '\0')
        return [NSString stringWithFormat:@"%s@%s", uuidStr, buf];
    else
        return @(uuidStr);
}

#pragma mark - === Helper === -

+ (BOOL)stringA:(NSString *)a doesNotMatch:(NSString *)b {
    if (a == nil && b != nil)
        return YES;
    
    if (a != nil && b == nil)
        return YES;
    
    if (a == nil && b == nil)
        return NO;
    
    return ![a isEqualToString:b];
}

- (BOOL)isEqualToEvent:(const EKEvent *const)other {
    if ([EKEvent stringA:self.title doesNotMatch:other.title])
        return NO;
    
    if ([EKEvent stringA:self.location doesNotMatch:other.location])
        return NO;
    
    if ([EKEvent stringA:self.notes doesNotMatch:other.notes])
        return NO;
    
    if (self.allDay != other.allDay)
        return NO;
    
    if (self.hasRecurrenceRules) {
        if (!other.hasRecurrenceRules)
            return NO;
        
        const EKRecurrenceRule *const ar = [self.recurrenceRules firstObject];
        const EKRecurrenceRule *const br = [other.recurrenceRules firstObject];
        
        if (ar.frequency != br.frequency)
            return NO;
        
        if (ar.interval != br.interval)
            return NO;
        
        const EKRecurrenceEnd *const ae = ar.recurrenceEnd;
        const EKRecurrenceEnd *const be = br.recurrenceEnd;
        
        if (ae) {
            if (!be)
                return NO;
            
            if (![ae.endDate isEqualToDate:be.endDate])
                return NO;
        } else if (be)
            return NO;
    } else if (other.hasRecurrenceRules)
        return NO;
    
    return YES;
}



@end
