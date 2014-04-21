//
//  InjuryStatusEditorViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/4/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "InjuryStatus.h"

@class Injury, Person;

@interface InjuryStatusEditorViewController : UIViewController

@property (nonatomic, strong) Injury *injury;
@property (nonatomic, strong) Person *person;
@property (nonatomic, assign) InjuryStatusType statusType;

@end
