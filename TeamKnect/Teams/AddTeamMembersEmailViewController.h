//
//  AddTeamMembersEmailViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/13/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddTeamMembersEmailViewController : UIViewController

@property (nonatomic, readonly, strong) NSArray *emails;
@property (nonatomic, copy) NSArray *initialEmails;
@property (nonatomic, copy) NSString *roleName;

@end
