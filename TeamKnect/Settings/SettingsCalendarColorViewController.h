//
//  SettingsCalendarColorViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/10/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCalendarColorViewController : UIViewController

@property (nonatomic, readonly, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *initialColor;

@end
