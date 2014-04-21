//
//  MyWantViewController.h
//  TeamkNect
//
//  Created by Jangsan on 3/31/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface MyWantViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton             *btnBack;           //-----back button event.
@property (strong, nonatomic) IBOutlet UITableView          *tbl_Want;          //-----want tableview.

- (IBAction)btnBackClicked:(id)sender;

@end
