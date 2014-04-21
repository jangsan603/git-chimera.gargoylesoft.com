//
//  AddTeamMemberChooseRoleViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/13/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddTeamMemberChooseRoleViewController : UIViewController

@property (nonatomic, strong) NSMutableDictionary *peopleByRole;
@property (nonatomic, strong) Team *team;

// NSManagedObject (aka Team) does not keep a strong reference to its own
// managedObjectContext.  Because this team was created in a child context
// we have to store a strong reference ourselves because the Exit Segue we
// go to is from before the context is created, which would thus invalidate
// it and make all the data in team be nil
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
