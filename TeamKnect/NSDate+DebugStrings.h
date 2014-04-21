//
//  NSDate+DebugStrings.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DebugStrings)

- (NSString *)justDate;
- (NSString *)dateAndTime;
- (NSString *)dateAndTime:(NSString *const)timeZoneName;

@end
