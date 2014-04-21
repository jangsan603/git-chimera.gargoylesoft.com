//
//  UIStoryboardSegue+TopViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "UIStoryboardSegue+TopViewController.h"

@implementation UIStoryboardSegue (TopViewController)

- (id)realDestinationViewController {
    id top = [self destinationViewController];

    if ([top isKindOfClass:[UINavigationController class]])
        return [(UINavigationController *)top topViewController];
    else
        return top;
}

@end
