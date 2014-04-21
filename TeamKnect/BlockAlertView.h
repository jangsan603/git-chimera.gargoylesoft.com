//
//  BlockAlertView.h
//  Brackets
//
//  Created by Scott Grosch on 4/11/11.
//  Copyright 2011 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AlertBlock)(UIAlertView *alert);
typedef void (^ButtonAlertBlock)(UIAlertView *alert, NSInteger buttonIndex);
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
typedef void (^TextAlertBlock)(NSString *text);
typedef BOOL (^EnableCheckBlock)(const NSString *const text);
#endif

@interface BlockAlertView : UIAlertView <UIAlertViewDelegate>
              
@property (nonatomic, copy) ButtonAlertBlock clickedButtonAtIndex;
@property (nonatomic, copy) ButtonAlertBlock didDismissWithButtonIndex;
@property (nonatomic, copy) ButtonAlertBlock willDismissWithButtonIndex;
@property (nonatomic, copy) AlertBlock didPresentAlertView;
@property (nonatomic, copy) AlertBlock willPresentAlertView;
@property (nonatomic, copy) dispatch_block_t emptyDismissBlock;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
@property (nonatomic, copy) TextAlertBlock didDismissText;
@property (nonatomic, copy) EnableCheckBlock enableCheck;

+ (void)textWithTitle:(const NSString *const)title message:(const NSString *const)message initialText:(const NSString *const)initialText enableCheckBlock:(EnableCheckBlock)enableCheck dismissBlock:(TextAlertBlock)block;
+ (void)textCancelWithTitle:(const NSString *const)title message:(const NSString *const)message initialText:(const NSString *const)initialText enableCheckBlock:(EnableCheckBlock)enableCheck dismissBlock:(TextAlertBlock)block;
#endif

+ (void)okWithTitle:(const NSString *const)title message:(const NSString *const)message dismissBlock:(dispatch_block_t)block;
+ (void)okWithTitle:(const NSString *const)title message:(const NSString *const)message;

+ (void)okWithMessage:(const NSString *const)message;
+ (void)okWithMessage:(const NSString *const)message dismissBlock:(dispatch_block_t)block;

+ (void)okCancelWithTitle:(const NSString *const)title message:(const NSString *const)message dismissBlock:(ButtonAlertBlock)block;

@end
