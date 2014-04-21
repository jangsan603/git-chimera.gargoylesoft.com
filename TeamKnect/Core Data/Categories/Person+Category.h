//
//  Person+Category.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "Person.h"

@interface Person (Category)

+ (NSString *)formattedNameWithFirst:(NSString *)first last:(NSString *)last lastFirst:(BOOL)lastFirst;
+ (NSString *)formattedNameWithFirst:(NSString *)first last:(NSString *)last;

+ (void)convertToFeet:(int *)feet inches:(CGFloat *)inches fromMeters:(CGFloat)height;
+ (CGFloat)convertToMetricFromFeet:(const int)feet inches:(const CGFloat)inches;
+ (CGFloat)convertToMetricFromPounds:(const CGFloat)pounds;
+ (CGFloat)convertToImperialFromKilograms:(const CGFloat)kilos;

- (NSString *)formattedName;
- (NSString *)formattedWeight;
- (NSString *)formattedHeight;

- (BOOL)isMe;
- (void)assignImage:(UIImage *)image;

@end
