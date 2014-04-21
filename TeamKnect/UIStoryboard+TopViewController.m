//
//  UIStoryboard+TopViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "UIStoryboard+TopViewController.h"

@implementation UIStoryboard (TopViewController)

- (id)instantiateRealViewControllerWithIdentifier:(NSString *)identifier {
    id top = [self instantiateViewControllerWithIdentifier:identifier];

    if ([top isKindOfClass:[UINavigationController class]])
        return [(UINavigationController *)top topViewController];
    else
        return top;
}

@end
