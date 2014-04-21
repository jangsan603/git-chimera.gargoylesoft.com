//
//  GSCalendarListViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/27/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@class Team;

typedef void (^GSCalendarListSelectBlock)(Team *team, EKCalendar *calendar);

@interface GSCalendarListViewController : UITableViewController

@property (nonatomic, copy) GSCalendarListSelectBlock onSelect;

@end
