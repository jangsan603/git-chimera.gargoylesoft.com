//
//  MyMessagesViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/1/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import "MyMessagesCell.h"
#import "MyMessagesViewController.h"
#import "ChatRoomViewController.h"

@interface MyMessagesViewController ()

@end

@implementation MyMessagesViewController

@synthesize  btnBack;
@synthesize tbl_MessageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString  *myMessageCellIdentifier = @"myMessageCell";
    MyMessagesCell   *cell;
    cell                                      = (MyMessagesCell *)[tableView dequeueReusableCellWithIdentifier:myMessageCellIdentifier];
    if (cell == nil)
    {
        cell                      = [[MyMessagesCell alloc]initWithFrame:CGRectZero];
        cell.accessoryType        = UITableViewCellAccessoryNone;
        cell.selectionStyle       = UITableViewCellSelectionStyleNone;
    }
    cell.lblName.text             = @"Me & Xenia";
    cell.lblDetail.text           = @"Love the t-shirt!!! Can";
    cell.lblDate.text             = @"yesterday 12:01";
    cell.imgViewUser.image        = [UIImage imageNamed:@"4.jpg"];
    cell.imgViewDirection.image   = [UIImage imageNamed:@"tbl_direction.png"];
    cell.backgroundColor          = [UIColor colorWithRed:0.913 green:0.929 blue:0.945 alpha:1.0];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        ChatRoomViewController *vc = [[ChatRoomViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 1)
    {
    
    }
    if (indexPath.row == 2)
    {
    
    }
    if (indexPath.row == 3)
    {

    }
    if (indexPath.row == 4)
    {
    
    }
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
