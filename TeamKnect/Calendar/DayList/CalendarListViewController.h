//
//  CalendarListViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarDisplayProtocol.h"

@interface CalendarListViewController : UIViewController <CalendarDisplayProtocol>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Team *team;

@end
