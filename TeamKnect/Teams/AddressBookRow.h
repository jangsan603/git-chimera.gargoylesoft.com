//
//  AddressBookRow.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/24/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressBookRow : NSObject

@property (nonatomic, unsafe_unretained) BOOL selected;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;

@end
