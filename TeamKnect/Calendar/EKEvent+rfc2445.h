//
//  EKEvent+rfc2445.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/4/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface RFC2445 : NSObject
@property (nonatomic, strong) NSDate *startDate, *endDate;
@property (nonatomic, copy) NSString *location, *summary, *uid, *notes;
@property (nonatomic, assign) BOOL allDay;
@property (nonatomic, copy) EKRecurrenceRule *recurrenceRule;
@property (nonatomic, copy) NSArray *exclusions;
@end

@interface EKEvent (rfc2445)

/**
 Generates an RFC2445 representation of an @c EKEvent with a specific @c UID
 @see http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html
 @param uid
 The value to apply to the UID field instead of a random UID.
 @return The RFC2445 @c VEVENT string.
 */
- (NSString *)toRfc2445WithUID:(const NSString *const)uid;

/**
 Generates an RFC2445 representation of an @c EKEvent
 @see http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html
 @note This will generate a new UID every time it is called!
 @return The RFC2445 @c VEVENT string.
 */
- (NSString *)toRfc2445;

/**
 Updates the receiver based on an RFC2445 VEVENT.
 @see http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html
 @param str
 The RFC2445 string.
 @param exclusions
 Will be populated with a list of @c EXDATE exclusions.
 @return The @c UID of the imported @c VEVENT
 */
- (NSString *)populateFromRfc2445string:(const NSString *const)str exclusions:(NSArray __strong **)exclusions;

/**
 Updates the receiver based on an RFC2445 VEVENT.
 @see http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html
 @param rfc2445
 The RFC2445 object
 */
- (void)populateFromRfc2445:(const RFC2445 *const)rfc2445;

/**
 Parses an RFC2445 string into its components.
 @see http://google-rfc-2445.googlecode.com/svn/trunk/rfc2445.html
 @param str
 The RFC2445 string.
 */
+ (RFC2445 *)initRfc2445:(const NSString *const)str;


/**
 * Returns an @c NSDateFormatter suitable to print out a date and time.
 */
+ (NSDateFormatter *)dateAndTimeFormatter NS_RETURNS_RETAINED;

/**
 * Returns an @c NSDateFormatter suitable to print out a date without a time.
 */
+ (NSDateFormatter *)dateOnlyFormatter NS_RETURNS_RETAINED;

+ (NSString *)uid;
- (BOOL)isEqualToEvent:(const EKEvent *const)other;
+ (NSDate *)dateFromString:(const NSString *const)str hasTimeComponent:(BOOL *)hasTimeComponent;

@end

