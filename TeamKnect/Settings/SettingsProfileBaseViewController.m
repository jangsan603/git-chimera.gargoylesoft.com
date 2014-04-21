//
//  SettingsProfileBaseViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 4/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsProfileBaseViewController.h"

@implementation SettingsProfileBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.title = [LocalizedStrings nextButton];
}

- (void)setupTextField:(UITextField *)field text:(NSString *)text placeholder:(NSString *)placeholder imageNamed:(NSString *)imageName {
    field.text = text;
    field.placeholder = placeholder;
    
    if (imageName) {
        field.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        field.leftViewMode = UITextFieldViewModeAlways;
    }
}

@end
