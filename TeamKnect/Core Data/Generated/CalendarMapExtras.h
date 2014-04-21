//
//  CalendarMapExtras.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CalendarMap;

@interface CalendarMapExtras : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * eventIdentifier;
@property (nonatomic, retain) NSString * rfc2445;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) CalendarMap *calendarMap;

@end
