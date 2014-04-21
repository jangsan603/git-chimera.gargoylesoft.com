//
//  PersonContactInfoViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/2/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "PersonDetailsProtocol.h"

@class Person;

@interface PersonContactInfoViewController : UITableViewController <PersonDetailsProtocol>

@property (nonatomic, strong) Person *person;

@end
