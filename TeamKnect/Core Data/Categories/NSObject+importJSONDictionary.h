//
//  NSObject+importJSONDictionary.h
//  I AM ANP APP
//
//  Created by Scott Grosch on 1/11/12.
//  Copyright (c) 2012 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (importJSONDictionary)

- (void)importJSONDictionary:(const NSDictionary *const)dict dateFormat:(const NSString *const)format class:(Class)class;
- (void)importJSONDictionary:(const NSDictionary *const)dict dateFormat:(const NSString *const)format;
- (void)importJSONDictionary:(const NSDictionary *const)dict;

@end
