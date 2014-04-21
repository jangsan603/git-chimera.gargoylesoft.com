//
//  CalendarListTableViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/13/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarListTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDate *dayBeingDisplayed;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) Team *team;

- (void)moveByDays:(const NSInteger)days;

@end
