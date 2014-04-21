//
//  EditAdViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/4/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//

#import "EditAdViewController.h"

@interface EditAdViewController ()

@end

@implementation EditAdViewController

@synthesize  btnCancel, btnChangePrice, btnSave, btnCamera;
@synthesize  imgOldCategory, lblCost, tblInfo;

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

- (IBAction)btnCancelClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSaveClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnChangePriceClicked:(id)sender
{
    
}

- (IBAction)btnCameraClicked:(id)sender
{
    
}

#pragma mark - TableViewDelegate.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString  *cellIdentifier = @"categoryInfoCell";
    UITableViewCell   *cell;
    cell                             = [tblInfo dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell                      = [[UITableViewCell alloc]initWithFrame:CGRectZero];
        cell.accessoryType        = UITableViewCellAccessoryNone;
        cell.selectionStyle       = UITableViewCellSelectionStyleNone;
    }
//    [tblInfo setSeparatorColor:[UIColor clearColor]];
    UILabel *label                = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 20)];
    label.font                    = [UIFont systemFontOfSize:13.0];
    label.textColor               = [UIColor colorWithRed:0.062 green:0.282 blue:0.466 alpha:1.0];
    UILabel *detailLabel          = [[UILabel alloc]initWithFrame:CGRectMake(20, 28, 200, 18)];
    detailLabel.textColor         = [UIColor colorWithRed:0.4 green:0.419 blue:0.439 alpha:1.0];
    if (indexPath.row == 0)
    {
        label.text          = @"Name";
        detailLabel.text    = @"Pink Shoes";
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:detailLabel];
    }
    if (indexPath.row == 1)
    {
        label.text          = @"Category";
        detailLabel.text    = @"Football";
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:detailLabel];
    }
    if (indexPath.row == 2)
    {
        label.text          = @"Condition";
        detailLabel.text    = @"Used";
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:detailLabel];
    }
    if (indexPath.row == 3)
    {
        UIImageView     *imgView      = [[UIImageView alloc]initWithFrame:CGRectMake(300, 15, 8, 13)];
        imgView.image                 = [UIImage imageNamed:@"tbl_direction"];
        label.text          = @"Description";
        detailLabel.text    = @"Prague ceska republic";
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:detailLabel];
        [cell.contentView addSubview:imgView];
    }
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
