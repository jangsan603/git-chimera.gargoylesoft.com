//
//  PersonDetailsInfoViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/21/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "PersonDetailsProtocol.h"

@class TeamPerson;

@interface PersonDetailsInfoViewController : UITableViewController <PersonDetailsProtocol>

@property (nonatomic, strong) TeamPerson *teamPerson;

@end
