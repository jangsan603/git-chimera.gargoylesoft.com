//
//  UIStoryboard+TopViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (TopViewController)

- (id)instantiateRealViewControllerWithIdentifier:(NSString *)identifier;

@end
