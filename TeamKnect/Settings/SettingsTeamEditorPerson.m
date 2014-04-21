//
//  SettingsTeamEditorPerson.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/23/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsTeamEditorPerson.h"
#import "Person+Category.h"

@implementation SettingsTeamEditorPerson

- (instancetype)initWithPerson:(const Person *const)person {
    if ((self = [super init])) {
        self.first = person.first;
        self.last = person.last;     
        self.joined = YES;
        self.sql = person.sql_ident;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(const NSDictionary *const)dict {
    if ((self = [super init])) {
        self.first = dict[@"first"];
        self.last = dict[@"last"];
        if ([self.last isEqual:[NSNull null]]) {
            // It's an email address
            self.first = [self.first lowercaseStringWithLocale:[NSLocale currentLocale]];
            self.last = nil;
        }
        
        self.joined = NO;
        self.sql = @([dict[@"sql_ident"] longValue]);
    }
    
    return self;
}


// We want to check for item already being in a set, so need this

- (NSUInteger)hash {
    return [[self.first lowercaseStringWithLocale:nil] hash] ^ [[self.last lowercaseStringWithLocale:nil] hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return NO;
    
    SettingsTeamEditorPerson *o = (SettingsTeamEditorPerson *)object;

    if ([self.first localizedCaseInsensitiveCompare:o.first] != NSOrderedSame)
        return NO;
    
    if (self.last || o.last) {
        if (self.last == nil || o.last == nil)
            return NO;
        
        if ([self.last localizedCaseInsensitiveCompare:o.last] != NSOrderedSame)
            return NO;
    }
    
    if (self.joined != o.joined)
        return NO;
    
    if (![self.sql isEqualToNumber:o.sql])
        return NO;

    return YES;
}

@end
