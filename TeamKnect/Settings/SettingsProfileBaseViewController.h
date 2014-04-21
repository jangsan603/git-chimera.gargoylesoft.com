//
//  SettingsProfileBaseViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "Person+Category.h"

@interface SettingsProfileBaseViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *editContext;
@property (nonatomic, strong) Person *person;

- (void)setupTextField:(UITextField *)field text:(NSString *)text placeholder:(NSString *)placeholder imageNamed:(NSString *)imageName;

#define VALIDATE(var, str) NSString *var = [self.var.text stringByTrimmingCharactersInSet:ws]; if (var.length == 0) { [BlockAlertView okWithMessage:str]; return NO; }

@end
