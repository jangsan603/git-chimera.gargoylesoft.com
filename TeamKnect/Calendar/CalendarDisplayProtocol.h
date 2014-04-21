//
//  CalendarDisplayProtocol.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/14/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@class Team;

@protocol CalendarDisplayProtocol <NSObject>

@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
