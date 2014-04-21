//
//  MyWantViewController.m
//  TeamkNect
//
//  Created by Jangsan on 3/31/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import "MyWantCell.h"
#import "MyWantViewController.h"

@interface MyWantViewController ()

@end

@implementation MyWantViewController

@synthesize  btnBack;
@synthesize tbl_Want;

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

#pragma mark - TableViewDelegate.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString  *myWantCellIdentifier = @"myWantCell";
    MyWantCell   *cell;
    cell                                   = (MyWantCell *)[tableView dequeueReusableCellWithIdentifier:myWantCellIdentifier];
    if (cell == nil)
    {
        cell                      = [[MyWantCell alloc]initWithFrame:CGRectZero];
        cell.accessoryType        = UITableViewCellAccessoryNone;
        cell.selectionStyle       = UITableViewCellSelectionStyleNone;
    }
//    [tbl_Want setSeparatorColor:[UIColor clearColor]];
    cell.lblCategoryName.text     = @"A Soccer Ball";
    cell.lblDetail.text           = @"Lorem lpsum is simply dummy text of the prince";
    cell.imgViewCheck.image       = [UIImage imageNamed:@"tbl_check.png"];
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
