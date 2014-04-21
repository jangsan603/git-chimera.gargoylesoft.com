//
//  InjuryStatusHistoryViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/19/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "PersonDetailsProtocol.h"

@class Person;

@interface InjuryStatusHistoryViewController : UITableViewController <PersonDetailsProtocol>

@property (nonatomic, strong) Person *person;

@end
