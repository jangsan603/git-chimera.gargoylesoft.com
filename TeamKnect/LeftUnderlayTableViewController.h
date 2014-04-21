//
//  LeftUnderlayTableViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/10/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SWRevealViewController.h"
#import "HomeViewController.h"

@interface LeftUnderlayTableViewController : UITableViewController<SWRevealViewControllerDelegate>
{
    HomeViewController     *homeViewController;                     //------Jangsan. 0421
}

@property (nonatomic, strong) NSManagedObjectContext           *managedObjectContext;
@property (strong, nonatomic) SWRevealViewController           *swViewController;
@property (strong, nonatomic) UINavigationController           *naviController;

@end
