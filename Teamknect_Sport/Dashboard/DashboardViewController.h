//
//  DashboardViewController.h
//  TeamkNect
//
//  Created by Jangsan on 3/31/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface DashboardViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton            *btnBack;            //-------back button event.
@property (strong, nonatomic) IBOutlet UIButton            *btnAdd;             //-------add  button event.
@property (strong, nonatomic) IBOutlet UIScrollView        *scrollView;         //-------add  category image scroll.

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnAddClicked:(id)sender;

@end
