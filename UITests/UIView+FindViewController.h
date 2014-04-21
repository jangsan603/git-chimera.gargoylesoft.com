//
//  UIView+FindViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/21/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FindViewController)
- (UIViewController *) firstAvailableViewController;
- (id) traverseResponderChainForUIViewController;
@end