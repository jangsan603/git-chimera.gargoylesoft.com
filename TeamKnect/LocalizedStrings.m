//
//  LocalizedStrings.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "LocalizedStrings.h"

@implementation LocalizedStrings

+ (NSString *)nextButton {
    return NSLocalizedString(@"NEXT_BUTTON", @"'Next' label for the navigation bar button");
}

+ (NSString *)emailPlaceholder {
    return NSLocalizedString(@"EMAIL_PLACEHOLDER", @"Placeholder text asking for email address");
}

+ (NSString *)passwordPlaceholder {
    return NSLocalizedString(@"PASSWORD_PLACEHOLDER", @"Placeholder text asking for password");
}

+ (NSString *)retypePasswordPlaceholder {
    return NSLocalizedString(@"RETYPE_PASSWORD_PLACEHOLDER", @"Placeholder text asking for password to be validated");
}

+ (NSString *)firstNamePlaceholder {
    return NSLocalizedString(@"FIRST_NAME_PLACEHOLDER", @"Placeholder text asking for first name");
}

+ (NSString *)lastNamePlaceholder {
    return NSLocalizedString(@"LAST_NAME_PLACEHOLDER", @"Placeholder text asking for last name");
}

+ (NSString *)birthdayPlaceholder {
    return NSLocalizedString(@"BIRTHDATE", @"Placeholder for text asking for birthday");
}

+ (NSString *)emailMissing {
    return NSLocalizedString(@"MISSING_EMAIL", @"Message stating that the email address must be filled in.");
}

+ (NSString *)firstNameMissing {
    return NSLocalizedString(@"MISSING_FIRST_NAME", @"Message stating that the first name must be filled in.");
}

+ (NSString *)lastNameMissing {
    return NSLocalizedString(@"MISSING_LAST_NAME", @"Message stating that the last name must be filled in.");
}

+ (NSString *)passwordMissing {
    return NSLocalizedString(@"MISSING_PASSWORD", @"Message stating that the password field must be filled in.");
}

+ (NSString *)passwordTooShort {
    return NSLocalizedString(@"PASSWORD_TOO_SHORT", @"Password must be at least 6 characters long.");
}

+ (NSString *)birthdayMissing {
    return NSLocalizedString(@"MISSING_BIRTHDAY", @"Message stating that the birthday field must be filled in.");
}

+ (NSString *)injuryStatusAway {
    return NSLocalizedString(@"INJURY_STATUS_AWAY", @"Person is not injured, but they're not available");
}

+ (NSString *)injuryStatusOut {
    return NSLocalizedString(@"INJURY_STATUS_OUT", @"Person is injured and not able to play");
}

+ (NSString *)injuryStatucPractice {
    return NSLocalizedString(@"INJURY_STATUS_PRACTICE", @"Person is unable to play, but can still attend practice");
}

+ (NSString *)injuryStatusHealthy {
    return NSLocalizedString(@"INJURY_STATUS_HEALTHY", @"Person is healthy");
}

+ (NSString *)repeatNone {
    return NSLocalizedString(@"REPEAT_NONE", @"Never repeat calendar appointment.");
}

+ (NSString *)repeatDaily {
    return NSLocalizedString(@"REPEAT_DAILY", @"Repeat calendar item every day");
}

+ (NSString *)repeatWeekly {
    return NSLocalizedString(@"REPEAT_WEEKLY", @"Repeat calendar item every week");
}

+ (NSString *)repeatEveryTwoWeeks {
    return NSLocalizedString(@"REPEAT_EVERY_TWO_WEEKS", @"Repeat calendar item every two weeks.");
}

+ (NSString *)repeatMonthly {
    return NSLocalizedString(@"REPEAT_MONTHLY", @"Repeat calendar item every month");
}

+ (NSString *)repeatYearly {
    return NSLocalizedString(@"REPEAT_YEARLY", @"Repeat calendar item every year");
}

+ (NSString *)repeatEndNever {
    return NSLocalizedString(@"REPEAT_END_NEVER", @"Text for the end date when the event never stops repeating");
}

+ (NSString *)tryLater {
    return NSLocalizedString(@"SERVER_DOWN_TRY_LATER", @"Message saying we couldn't talk to the webserver and to please try again later.");
}

+ (NSString *)dateOfReturn {
    return NSLocalizedString(@"DATE_OF_RETURN", @"Label for table for date of return");
}

+ (NSString *)dateOfInjury {
    return NSLocalizedString(@"DATE_OF_INJURY", @"Label for table for date of injury");
}

+ (NSString *)injurySite {
    return NSLocalizedString(@"INJURY_SITE", @"Label for the location of the injury");
}

+ (NSString *)injuryDetails {
    return NSLocalizedString(@"INJURY_DETAILS", @"Label for the details of the injury");
}

+ (NSString *)injuryAvailability {
    return NSLocalizedString(@"INJURY_AVAILABILITY", @"Label for the availability of the player based on their injury status");
}

+ (NSString *)feetLabel {
    if (IS_USING_METRIC)
        return NSLocalizedString(@"PROFILE_METERS_LABEL", @"Label for the height in meters.");
    else
        return NSLocalizedString(@"PROFILE_FEET_LABEL", @"Label for the height in feet.");
}

+ (NSString *)inchesLabel {
    return NSLocalizedString(@"PROFILE_INCHES_LABEL", @"Label for the height in inches.");
}

+ (NSString *)poundsLabel {
    if (IS_USING_METRIC)
        return NSLocalizedString(@"PROFILE_KG_LABEL", @"Label for the height in KG");
    else
        return NSLocalizedString(@"PROFILE_LBS_LABEL", @"Label for the height in pounds.");
}

+ (NSString *)birthdayLabel {
    return NSLocalizedString(@"PROFILE_BIRTHDAY_LABEL", @"Label for the birthday.");
}

+ (NSString *)feetMissing {
    if (IS_USING_METRIC)
        return NSLocalizedString(@"PROFILE_METERS_MISSING", @"Message stating that the height must be entered.");
    else
        return NSLocalizedString(@"PROFILE_FEET_MISSING", @"Message stating that the height in feet must be entered.");
}

+ (NSString *)inchesMissing {
    return NSLocalizedString(@"PROFILE_INCHES_MISSING", @"Message stating that the inches must be entered.");
}

+ (NSString *)poundsMissing {
    if (IS_USING_METRIC)
        return NSLocalizedString(@"PROFILE_KG_MISSING", @"Message stating that the KG must be entered");
    else
        return NSLocalizedString(@"PROFILE_POUNDS_MISSING", @"Message stating that the lbs must be entered.");
}

+ (NSString *)poundsPlaceholder {
    if (IS_USING_METRIC)
        return NSLocalizedString(@"PROFILE_KG_PLACEHOLDER", @"Placeholder message for weight in KG");
    else
        return NSLocalizedString(@"PROFILE_POUNDS_PLACEHOLDER", @"Placeholder message for weight in pounds");
}

+ (NSString *)feetPlaceholder {
    if (IS_USING_METRIC)
        return NSLocalizedString(@"PROFILE_METERS_PLACEHOLDER", @"Placeholder string for height in meters");
    else
        return NSLocalizedString(@"PROFILE_FEET_PLACEHOLDER", @"Placeholder string for height in feet");
}

+ (NSString *)calendarEventSpansAllDay {
    return NSLocalizedString(@"CALENDAR_ALL_DAY", @"Text saying that a calendar event runs the entire day.");
}

@end


