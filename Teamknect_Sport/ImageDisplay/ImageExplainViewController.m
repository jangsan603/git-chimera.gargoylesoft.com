//
//  ImageExplainViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/2/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import "Global.h"
#import "ImageExplainViewController.h"
#import "MyWantViewController.h"
#import "SendMessageViewController.h"
#import "CategoryViewController.h"
#import "FullImageViewController.h"

@interface ImageExplainViewController ()

@end

@implementation ImageExplainViewController
@synthesize scrollView, mapView, tblMoreInfo;
@synthesize btnBack, btnMessage,btnSetting, btnImgDisplay;
@synthesize lblCommodityTitle;

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
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 61, 320, 710)];
    scrollView.contentSize = view.frame.size;
    
    if (globalSelectDetailImgIndex == 60)
    {
        lblCommodityTitle.text = @"Most beautifull dress";
//        [btnName setTitle:@"Miriam N" forState:UIControlStateNormal];
    }
    if (globalSelectDetailImgIndex == 61)
    {
        lblCommodityTitle.text = @"Cute t-shirt";

    }
    if (globalSelectDetailImgIndex == 62)
    {
        lblCommodityTitle.text = @"Nice hat";

    }
    if (globalSelectDetailImgIndex == 63)
    {
        lblCommodityTitle.text = @"Rain boots";

    }
    if (globalSelectDetailImgIndex == 64)
    {
        lblCommodityTitle.text = @"Ball";

    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (globalSelectDetailImgIndex_1 == 70)
    {
        lblCommodityTitle.text = @"Cute t-shirt";
    }
    if (globalSelectDetailImgIndex_1 == 71)
    {
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    globalSelectDetailImgIndex_1 = 0;
    globalSelectDetailImgIndex   = 0;
}

- (IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSettingClicked:(id)sender
{
    MyWantViewController *vc = [[MyWantViewController alloc]initWithNibName:@"MyWantViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnMessageClicked:(id)sender
{
    SendMessageViewController *vc = [[SendMessageViewController alloc]initWithNibName:@"SendMessageViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnImgDisplayClicked:(id)sender
{
    FullImageViewController   *vc = [[FullImageViewController alloc]initWithNibName:@"FullImageViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnBuyForClicked:(id)sender
{
    
}

- (IBAction)btnSendMsgClicked:(id)sender
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
    static NSString  *cellIdentifier = @"moreInfoCell";
    UITableViewCell   *cell;
    cell                          = [tblMoreInfo dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell                      = [[UITableViewCell alloc]initWithFrame:CGRectZero];
        cell.accessoryType        = UITableViewCellAccessoryNone;
        cell.selectionStyle       = UITableViewCellSelectionStyleNone;
    }
//    [tblMoreInfo setSeparatorColor:[UIColor clearColor]];
    UIImageView     *imgView      = [[UIImageView alloc]initWithFrame:CGRectMake(300, 18, 8, 13)];
    imgView.image                 = [UIImage imageNamed:@"tbl_direction"];
    cell.backgroundColor          = [UIColor colorWithRed:0.956 green:0.964 blue:0.968 alpha:1.0];
    UILabel *label                = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 20)];
    label.font                    = [UIFont systemFontOfSize:13.0];
    label.textColor               = [UIColor colorWithRed:0.062 green:0.282 blue:0.466 alpha:1.0];
    UILabel *detailLabel          = [[UILabel alloc]initWithFrame:CGRectMake(20, 28, 200, 18)];
    detailLabel.textColor         = [UIColor colorWithRed:0.4 green:0.419 blue:0.439 alpha:1.0];
    if (indexPath.row == 0)
    {
        label.text          = @"Owner";
        detailLabel.text    = @"Miriam Nova";
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:detailLabel];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 1)
    {
        label.text          = @"Category";
        detailLabel.text    = @"Soccer";
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:detailLabel];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 2)
    {
        label.text          = @"Condition";
        detailLabel.text    = @"New";
        [cell.contentView addSubview:label];
        [cell.contentView addSubview:detailLabel];
    }
    if (indexPath.row == 3)
    {
         UIImageView     *imgView      = [[UIImageView alloc]initWithFrame:CGRectMake(290, 13, 18, 21)];
        imgView.image                  = [UIImage imageNamed:@"tbl_near"];
        label.text          = @"Location";
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
