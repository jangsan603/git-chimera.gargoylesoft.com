//
//  UITextView+VisibleBorder.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/8/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "UITextView+VisibleBorder.h"

@implementation UITextView (VisibleBorder)

- (void)showBorder {
    CALayer *layer = self.layer;
    layer.cornerRadius = 5.;
    layer.borderWidth = .5f;
    layer.shadowOpacity = .4;
    layer.shadowRadius = 5.;
    layer.shadowColor = [UIColor blackColor].CGColor;
}

@end
