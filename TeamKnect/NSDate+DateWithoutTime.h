//
//  NSDate+DateWithoutTime.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/19/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateWithoutTime)

+ (NSDate *)dateWithoutTime;
- (NSDate *)dateWithoutTime;

@end
