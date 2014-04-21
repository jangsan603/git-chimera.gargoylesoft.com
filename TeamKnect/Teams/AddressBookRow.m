//
//  AddressBookRow.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/24/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "AddressBookRow.h"

@implementation AddressBookRow

// We want to check for item already being in a set, so need this

- (NSUInteger)hash {
    return [self.email hash];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]] && [self.email isEqualToString:((AddressBookRow *)object).email];
}

@end
