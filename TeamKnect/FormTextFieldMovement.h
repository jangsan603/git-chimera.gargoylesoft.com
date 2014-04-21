//
//  FormTextFieldMovement.h
//  TeamKnect
//
//  Created by Scott Grosch on 12/28/13.
//  Copyright (c) 2013 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormTextFieldMovement : NSObject <UITextFieldDelegate>

- (void)setFormTextFields:(UITextField *)firstField, ... NS_REQUIRES_NIL_TERMINATION;
- (void)setFormTextFieldsWithArray:(NSArray *)ary;

@end
