//
//  MyMessagesViewController.h
//  TeamkNect
//
//  Created by Jangsan on 4/1/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface MyMessagesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIButton                   *btnBack;          //--------back button event.
@property (strong, nonatomic) IBOutlet UITableView                *tbl_MessageView;  //--------message tableView.

- (IBAction)btnBackClicked:(id)sender;

@end
