//
//  DashboardViewController.m
//  TeamkNect
//
//  Created by Jangsan on 3/31/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//
#import "ImageDetailViewController.h"
#import "DashboardViewController.h"
#import "NewAdViewController.h"
#import "DashImageView.h"



@interface DashboardViewController ()<DashImageDelegate>

@end

@implementation DashboardViewController

@synthesize btnAdd, btnBack;
@synthesize scrollView;

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
    CGFloat width       = 90;
    CGFloat height      = 140;
    CGFloat margin      = 13;
    CGFloat startX      = (self.view.frame.size.width - 3 * width - 2 * margin) *0.5;
    CGFloat startY      = 20;
    for (int i = 0; i<30; i++)
    {
        int row         = i/3;
        int column      = i%3;
        CGFloat      x  =  startX + column * (width +margin);
        CGFloat      y  =  startY + row  * (height + margin);
        DashImageView *dashView = [[DashImageView alloc] initWithFrame:CGRectMake(x, y, 90, 140)];
        [self.scrollView addSubview:dashView];
        dashView.delegate = self;
        dashView.dashImgSelectIndex = i;
   //        [dashView setDashImageUrl:<#(NSString *)#> CategoryName:(NSString *) CategoryCost:<#(NSString *)#>];
        
    }
    UIView   *view  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 11*140)];
    self.scrollView.contentSize = view.frame.size;
}

#pragma mark - imageview select method.
- (void)btnCategory_2Clicked:(int)index
{
    int selectIndex = index;
    switch (selectIndex)
    {
        case 0:
        {
            ImageDetailViewController *vc = [[ImageDetailViewController alloc]initWithNibName:@"ImageDetailViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)btnBackClicked:(id)sender
{
    [self.revealViewController revealToggleAnimated:YES];
}

- (IBAction)btnAddClicked:(id)sender
{
    NewAdViewController     *vc = [[NewAdViewController alloc] init];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
