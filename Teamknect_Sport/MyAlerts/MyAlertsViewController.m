//
//  MyAlertsViewController.m
//  TeamkNect
//
//  Created by Jangsan on 3/31/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import "MyAlertsCell.h"
#import "MyAlertsViewController.h"

@interface MyAlertsViewController ()

@end

@implementation MyAlertsViewController
@synthesize btnBack;
@synthesize tbl_AlertsView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - TableViewDelegate.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString  *myAlertsCellIdentifier = @"myAlertsCell";
    MyAlertsCell   *cell;
    cell                                      = (MyAlertsCell *)[tableView dequeueReusableCellWithIdentifier:myAlertsCellIdentifier];
    if (cell == nil)
    {
        cell                      = [[MyAlertsCell alloc]initWithFrame:CGRectZero];
        cell.accessoryType        = UITableViewCellAccessoryNone;
        cell.selectionStyle       = UITableViewCellSelectionStyleNone;
    }
    [tbl_AlertsView setSeparatorColor:[UIColor clearColor]];
    cell.lblItemName.text         = @"New Message";
    cell.lblDetailName.text       = @"Me & Diego";
    cell.lblDate.text             = @"yesterday 11:01";
    cell.imgViewItem.image        = [UIImage imageNamed:@"tbl_msg_white.png"];
    cell.imgViewDirection.image   = [UIImage imageNamed:@"tbl_direction.png"];
    cell.backgroundColor          = [UIColor colorWithRed:0.956 green:0.964 blue:0.968 alpha:1.0];
    
    return cell;
}

- (IBAction)btnBackClicked:(id)sender
{
     [self.revealViewController revealToggleAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
