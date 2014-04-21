//
//  Message+Category.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/11/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "Message+Category.h"

@implementation Message (Category)

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"Message: %@ %@ %@", self.sql_ident, [NSDateFormatter localizedStringFromDate:self.created dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle], self.text];
}

@end
