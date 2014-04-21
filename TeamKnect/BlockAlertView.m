//
//  BlockAlertView.m
//  Brackets
//
//  Created by Scott Grosch on 4/11/11.
//  Copyright 2011 Gargoyle Software, LLC. All rights reserved.
//

#import "BlockAlertView.h"

@implementation BlockAlertView

+ (BlockAlertView *)newBlockAlertViewWithTitle:(const NSString *const)title message:(const NSString *const)message usingCancel:(const BOOL)cancel {
    return [[BlockAlertView alloc] initWithTitle:(NSString *)title
                                         message:(NSString *)message
                                        delegate:self
                               cancelButtonTitle:cancel ? kCancelButton : nil
                               otherButtonTitles:NSLocalizedString(@"OK", @"The OK button"), nil];
}

+ (void)okWithTitle:(const NSString *const)title message:(const NSString *const)message dismissBlock:(dispatch_block_t)block {
    BlockAlertView *alert = [BlockAlertView newBlockAlertViewWithTitle:title message:message usingCancel:NO];
    alert.emptyDismissBlock = block;
    [alert show];
}

+ (void)okWithTitle:(const NSString *const)title message:(const NSString *const)message {
    [BlockAlertView okWithTitle:title message:message dismissBlock:nil];
}

+ (void)okWithMessage:(const NSString *const)message {
    [BlockAlertView okWithTitle:nil message:message dismissBlock:nil];
}

+ (void)okWithMessage:(const NSString *const)message dismissBlock:(dispatch_block_t)block {
    [BlockAlertView okWithTitle:nil message:message dismissBlock:block];
}

+ (void)okCancelWithTitle:(const NSString *const)title message:(const NSString *const)message dismissBlock:(ButtonAlertBlock)block {
    BlockAlertView *alert = [BlockAlertView newBlockAlertViewWithTitle:title message:message usingCancel:YES];
    alert.didDismissWithButtonIndex = block;
    [alert show];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
+ (void)internaltextWithTitle:(const NSString *const)title message:(const NSString *const)message initialText:(const NSString *const)initialText enableCheckBlock:(EnableCheckBlock)enableCheck dismissBlock:(TextAlertBlock)block usingCancel:(const BOOL)cancel {
    BlockAlertView *alert = [BlockAlertView newBlockAlertViewWithTitle:title message:message usingCancel:cancel];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    if (initialText)
        [alert textFieldAtIndex:0].text = (NSString *) initialText;
    
    alert.didDismissText = block;
    alert.enableCheck = enableCheck;
    
    [alert show];
}

+ (void)textWithTitle:(const NSString *const)title message:(const NSString *const)message initialText:(const NSString *const)initialText enableCheckBlock:(EnableCheckBlock)enableCheck dismissBlock:(TextAlertBlock)block {
    [BlockAlertView internaltextWithTitle:title message:message initialText:initialText enableCheckBlock:enableCheck dismissBlock:block usingCancel:NO];
}

+ (void)textCancelWithTitle:(const NSString *const)title message:(const NSString *const)message initialText:(const NSString *const)initialText enableCheckBlock:(EnableCheckBlock)enableCheck dismissBlock:(TextAlertBlock)block {
    [BlockAlertView internaltextWithTitle:title message:message initialText:initialText enableCheckBlock:enableCheck dismissBlock:block usingCancel:YES];
}
#endif

// When they show the alert, make sure we're the delegate, no matter what they might have specified.
- (void)show {
    self.delegate = self;
    [super show];
}

#pragma mark -
#pragma mark === Alert View Delegates ===
#pragma mark -

// Do not implement the cancel delegate.  The system checks to see if it's implemented and
// acts differently if it is or isn't.  If we implement it here, it's always implemented.

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if (alertView.alertViewStyle != UIAlertViewStylePlainTextInput)
        return YES;
    
    const UITextField *const textField = [alertView textFieldAtIndex:0];
    
    const NSString *const text = [[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (self.enableCheck && self.enableCheck(text) == NO)
        return NO;
    
    return text.length > 0;
}
#endif

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.clickedButtonAtIndex)
        self.clickedButtonAtIndex(alertView, buttonIndex);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.emptyDismissBlock)
        self.emptyDismissBlock();
    else if (self.didDismissWithButtonIndex)
        self.didDismissWithButtonIndex(alertView, buttonIndex);
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
    else if (self.didDismissText) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            self.didDismissText(nil);
            return;
        }
        
        const UITextField *const textField = [alertView textFieldAtIndex:0];
        NSString *const text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.didDismissText(text);
    }
#endif
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.willDismissWithButtonIndex)
        self.willDismissWithButtonIndex(alertView, buttonIndex);
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    if (self.didPresentAlertView)
        self.didPresentAlertView(alertView);
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if (self.willPresentAlertView)
        self.willPresentAlertView(alertView);
}

@end
