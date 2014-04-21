//
//  GSRevealViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/23/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

extern NSString *const GSRevealViewControllerToggleLeftViewController;
extern NSString *const GSRevealViewControllerReplaceFrontViewController;
extern NSString *const GSRevealViewControllerReplaceFrontViewControllerKey;

@interface GSRevealViewController : UIViewController

@property (nonatomic, assign) CGFloat leftNavigationPercentage;
@property (nonatomic, assign) CGFloat slideDuration;

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController leftViewController:(UIViewController *)leftViewController;

- (void)replaceFrontViewController:(UIViewController *)frontViewController;

- (void)toggleLeftDisplay;
- (void)showLeftDisplay;
- (void)hideLeftDisplay;

@end
