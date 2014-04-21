//
//  LocalizedStrings.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@interface LocalizedStrings : NSObject

+ (NSString *)nextButton;

+ (NSString *)emailPlaceholder;
+ (NSString *)passwordPlaceholder;
+ (NSString *)retypePasswordPlaceholder;
+ (NSString *)firstNamePlaceholder;
+ (NSString *)lastNamePlaceholder;
+ (NSString *)birthdayPlaceholder;

+ (NSString *)emailMissing;
+ (NSString *)firstNameMissing;
+ (NSString *)lastNameMissing;
+ (NSString *)passwordMissing;
+ (NSString *)birthdayMissing;

+ (NSString *)passwordTooShort;

+ (NSString *)injuryStatusAway;
+ (NSString *)injuryStatusOut;
+ (NSString *)injuryStatucPractice;
+ (NSString *)injuryStatusHealthy;

+ (NSString *)repeatNone;
+ (NSString *)repeatDaily;
+ (NSString *)repeatWeekly;
+ (NSString *)repeatEveryTwoWeeks;
+ (NSString *)repeatMonthly;
+ (NSString *)repeatYearly;
+ (NSString *)repeatEndNever;

+ (NSString *)tryLater;

+ (NSString *)dateOfReturn;
+ (NSString *)dateOfInjury;
+ (NSString *)injurySite;
+ (NSString *)injuryDetails;
+ (NSString *)injuryAvailability;

+ (NSString *)feetLabel;
+ (NSString *)inchesLabel;
+ (NSString *)poundsLabel;
+ (NSString *)birthdayLabel;
+ (NSString *)feetMissing;
+ (NSString *)inchesMissing;
+ (NSString *)poundsMissing;

+ (NSString *)poundsPlaceholder;
+ (NSString *)feetPlaceholder;

+ (NSString *)calendarEventSpansAllDay;

@end
