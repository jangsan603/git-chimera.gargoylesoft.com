//
//  UIView+Category.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/13/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)

- (NSArray *)constrainMeToMatchSuperview:(UIView *)superview
{
    UIView *subview = self;
    self.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *const viewsDictionary = NSDictionaryOfVariableBindings(subview);

    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|[subview]|"
                            options:0
                            metrics:nil
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:|[subview]|"
                    options:0
                    metrics:nil
                    views:viewsDictionary]];
    [superview addConstraints:constraints];

    return constraints;
}

@end
