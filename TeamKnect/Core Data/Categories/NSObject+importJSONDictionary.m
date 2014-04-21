//
//  NSObject+importJSONDictionary.m
//  I AM ANP APP
//
//  Created by Scott Grosch on 1/11/12.
//  Copyright (c) 2012 Gargoyle Software, LLC. All rights reserved.
//

#import "NSObject+importJSONDictionary.h"
#import <objc/runtime.h>
#import <time.h>
#import <xlocale.h>

@implementation NSObject (importJSONDictionary)

- (void)importJSONDictionary:(const NSDictionary *const)dict dateFormat:(const NSString *const)format class:(Class)class
{
    unsigned int count;
    const objc_property_t *const properties = class_copyPropertyList(class, &count);
    
    const NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    for (int i = count - 1; i >= 0; i--) {
        objc_property_t property = properties[i];
        
        const NSString *const propertyName = @(property_getName(property));
        
        // Make sure that the property on this class is actually listed in the JSON data
        id value = dict[propertyName];
        if (value == nil || value == [NSNull null])
            continue;
        
        const char *const attributeType = property_copyAttributeValue(property, "T");
        if (attributeType == NULL)
            continue;

//        NSLog(@"%@ has attribute type %s", propertyName, attributeType);

        switch (*attributeType) {
            case '@': {
                // The @ symbol means that this is an NSObject subclass.  Get the class name by stripping off the
                // leading @" symbols, and the trailing "
                const char *const className = strndup(attributeType + 2, strlen(attributeType) - 3);
                const Class class = NSClassFromString(@(className));
                free((void *)className);
                
                if (class == nil)
                    continue;
                
                // Check for type mismatch, attempt to compensate
                if ([class isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]])
                    value = [value stringValue];
                else if ([class isSubclassOfClass:[NSNumber class]] && [value isKindOfClass:[NSString class]])
                    value = [numberFormatter numberFromString:value];
                else if ([class isSubclassOfClass:[NSDate class]] && [value isKindOfClass:[NSString class]] && format != nil) {
                    struct tm atime;
                    memset(&atime, 0, sizeof(atime));
                    strptime_l([value UTF8String], [format UTF8String], &atime, NULL);
                    value = [NSDate dateWithTimeIntervalSince1970:mktime(&atime)];
                }
                
                break;
            }

            case 'd': // double
                value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
                break;
                
            case 'i': // int
            case 's': // short
            case 'l': // long
            case 'q': // long long
            case 'I': // unsigned int
            case 'S': // unsigned short
            case 'L': // unsigned long
            case 'Q': // unsigned long long
            case 'f': // float
            case 'B': // BOOL
                if ([value isKindOfClass:[NSString class]])
                    value = [numberFormatter numberFromString:value];
                
                break;
                
            case 'c': // char
            case 'C': // unsigned char
                if ([value isKindOfClass:[NSString class]])
                    value = @((char)[value characterAtIndex:0]);
                
                break;
                
                
            default:
                break;
        }
        
        [self setValue:value forKey:(NSString *) propertyName];
        free((void *)attributeType);
    }
    
    free((void *)properties);
}

- (void)importJSONDictionary:(const NSDictionary *const)dict dateFormat:(const NSString *const)format {
    [self importJSONDictionary:dict dateFormat:format class:[self class]];
    [self importJSONDictionary:dict dateFormat:format class:[self superclass]];
}

- (void)importJSONDictionary:(const NSDictionary *const)dict {
    [self importJSONDictionary:dict dateFormat:nil];
}

@end
