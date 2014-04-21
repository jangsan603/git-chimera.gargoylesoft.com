//
//  UIView+FindViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/21/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "UIView+FindViewController.h"



@implementation UIView (FindViewController)
- (UIViewController *) firstAvailableViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}
@end