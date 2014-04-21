//
//  Person+Category.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "Person+Category.h"
#import "InjuryStatus.h"
#import "Picture.h"

@implementation Person (Category)

+ (CGFloat)convertToMetricFromFeet:(const int)feet inches:(const CGFloat)inches {
    return ((CGFloat)feet * 12. + inches) * .0254;
}

+ (CGFloat)convertToMetricFromPounds:(const CGFloat)pounds {
    return pounds * 0.45359237;
}

+ (CGFloat)convertToImperialFromKilograms:(const CGFloat)kilos {
    // 1 kilogram is 2.204623 pounds
    return kilos * 2.204623;
}

+ (void)convertToFeet:(int *)feet inches:(CGFloat *)inches fromMeters:(CGFloat)height {
    // 1 m is 39.3700787401575 inches
    height *= 39.3700787401575;
    
    *feet = height / 12;
    *inches = fmodf(height, 12.);
}

+ (NSString *)formattedNameWithFirst:(NSString *)first last:(NSString *)last lastFirst:(BOOL)lastFirst {
    if ([last isEqual:[NSNull null]])
        last = nil;
    
    if ([first isEqual:[NSNull null]])
        first = nil;
    
    if (last && first) {
        if (lastFirst) {
            return [NSString stringWithFormat:NSLocalizedString(@"NAME_FORMATTED_LAST_FIRST", @"The format for showing names displayed with last name before first name"), last, first];
        } else {
            return [NSString stringWithFormat:NSLocalizedString(@"NAME_FORMATTED_FIRST_LAST", @"The format for showing names displayed with first name before last name"), first, last];
        }
    } else if (last)
        return last;
    else if (first)
        return first;
    else
        return NSLocalizedString(@"INCOMPLETE_PROFILE", @"Text used for player name when the name is missing");
}

+ (NSString *)formattedNameWithFirst:(NSString *)first last:(NSString *)last {
    return [Person formattedNameWithFirst:first last:last lastFirst:[[[NSUserDefaults standardUserDefaults] valueForKey:@"name_preference"] isEqualToString:@"lf"]];
}

- (NSString *)formattedName {
    return [Person formattedNameWithFirst:self.first last:self.last];
}

- (NSString *)formattedWeight {
    NSNumberFormatter *twoDecimalPlaces = [[NSNumberFormatter alloc] init];
    twoDecimalPlaces.numberStyle = NSNumberFormatterDecimalStyle;
    twoDecimalPlaces.maximumFractionDigits = 2;
    
    if (IS_USING_METRIC) {
        NSString *num = [twoDecimalPlaces stringFromNumber:self.weight];
        return [NSString stringWithFormat:NSLocalizedString(@"KG_WEIGHT_FORMAT", @"Weight formatted in kilograms"), num];
    } else {
        NSString *num = [twoDecimalPlaces stringFromNumber:@([[self class] convertToImperialFromKilograms:[self.weight floatValue]])];
        return [NSString stringWithFormat:NSLocalizedString(@"LBS_WEIGHT_FORMAT", @"Weight formatted in imperial pounds."), num];
    }
}

- (NSString *)formattedHeight {
    if (IS_USING_METRIC) {
        NSNumberFormatter *twoDecimalPlaces = [[NSNumberFormatter alloc] init];
        twoDecimalPlaces.numberStyle = NSNumberFormatterDecimalStyle;
        twoDecimalPlaces.maximumFractionDigits = 2;
        
        return [NSString stringWithFormat:NSLocalizedString(@"METERS", @"Height formatted as meters"), [twoDecimalPlaces stringFromNumber:self.height]];
    } else {
        int feet;
        CGFloat inches;
        [[self class] convertToFeet:&feet inches:&inches fromMeters:[self.height floatValue]];
        
        return [NSString stringWithFormat:NSLocalizedString(@"FEET_AND_INCHES", @"Height formatted as feet and inches"), feet, inches];
    }
}

- (BOOL)isMe {
    return [self.sql_ident isEqualToNumber:[[NSUserDefaults standardUserDefaults] valueForKey:@"me"]];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self setPrimitiveValue:@(InjuryStatusTypeOK) forKey:@"injury_status"];
}

// TODO: This should replace all the image assignments, and it should probably create the 100x100
// image version right here
- (void)assignImage:(UIImage *)image {
    if (!self.picture) {
        self.picture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:self.managedObjectContext];
        self.picture.person = self;
    }
    
    self.picture.image = UIImagePNGRepresentation(image);
    
    // Now create a properly scaled thumbnail that's 100x100 in size.
    
    CGFloat x = 0, y = 0;
    CGSize size = image.size;
    CGSize cropped;

    // Crop the image to the middle portion of the image so that the
    // height and width are the same.
    if (size.width > size.height) {
        x = (size.height - size.width) / -2.;
        cropped = CGSizeMake(size.height, size.height);
    } else {
        y = (size.width - size.height) / -2.;
        cropped = CGSizeMake(size.width, size.width);
    }
    
    CGRect rect = CGRectMake(x, y, cropped.width, cropped.height);
    CGImageRef thumb = CGImageCreateWithImageInRect(image.CGImage, rect);
    {
        size = CGSizeMake(100., 100.);
        rect = CGRectMake(0, 0, 100., 100.);
        
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
        {
            [[UIImage imageWithCGImage:thumb] drawInRect:rect];
            self.thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        }
        UIGraphicsEndImageContext();
    }
    CGImageRelease(thumb);
}

@end
