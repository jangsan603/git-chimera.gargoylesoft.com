//
//  FormTextFieldMovement.m
//  TeamKnect
//
//  Created by Scott Grosch on 12/28/13.
//  Copyright (c) 2013 Gargoyle Software, LLC. All rights reserved.
//

#import "FormTextFieldMovement.h"

@interface FormTextFieldMovement () {
    NSUInteger maxTextFieldIndex;
}
@property (nonatomic, strong) NSMutableArray *textFieldOrder;
@property (nonatomic, strong) UITextField *currentTextField;
@end

@implementation FormTextFieldMovement

#pragma mark - === Text Field Delegate === -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self nextTextField];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentTextField = nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.currentTextField != textField)
        [self.currentTextField resignFirstResponder];

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;
}

#pragma mark - === Text Field Movement === -

- (void)nextTextField {
    if (self.textFieldOrder == nil)
        return;

    NSUInteger index = [self.textFieldOrder indexOfObject:self.currentTextField];
    if (index == maxTextFieldIndex) {
        [self.currentTextField resignFirstResponder];
        self.currentTextField = nil;
    } else {
        self.currentTextField = self.textFieldOrder[index + 1];
        [self.currentTextField becomeFirstResponder];
    }
}

- (void)prevTextField {
    if (self.textFieldOrder == nil)
        return;

    NSInteger index = [self.textFieldOrder indexOfObject:self.currentTextField];
    if (index == 0) {
        [self.currentTextField resignFirstResponder];
        self.currentTextField = nil;
    } else {
        self.currentTextField = self.textFieldOrder[index - 1];
        [self.currentTextField becomeFirstResponder];
    }
}

#pragma mark - === Form Text Field Array management === -

- (void)setFormTextFields:(UITextField *)firstField, ... NS_REQUIRES_NIL_TERMINATION {
    va_list list;
    va_start(list, firstField);

    self.textFieldOrder = [[NSMutableArray alloc] init];
    [self.textFieldOrder addObject:firstField];

    UITextField *field;
    while ((field = va_arg(list, UITextField *)) != NULL) {
        field.delegate = self;
        [self.textFieldOrder addObject:field];
    }

    va_end(list);

    NSUInteger count = [self.textFieldOrder count];
#if DEBUG
    NSAssert(count, @"Must not call setFormTextFields with nil");
#endif

    maxTextFieldIndex = count - 1;
}

- (void)clearFormTextFields {
    self.textFieldOrder = nil;
}

- (void)setFormTextFieldsWithArray:(NSArray *)ary {
#if DEBUG
    NSAssert(ary.count > 0, @"ary must not be empty or nil");
#endif
    
    maxTextFieldIndex = [ary count];

    self.textFieldOrder = [[NSMutableArray alloc] initWithCapacity:maxTextFieldIndex];
    for (UITextField *obj in ary) {
        obj.delegate = self;
        [self.textFieldOrder addObject:obj];
    };
    
    maxTextFieldIndex--;
}


@end
