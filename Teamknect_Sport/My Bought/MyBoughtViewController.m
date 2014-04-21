//
//  MyBoughtViewController.m
//  TeamkNect
//
//  Created by Jangsan on 3/31/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import "BoughtImageView.h"
#import "MyBoughtViewController.h"
#import "NewAdViewController.h"

@interface MyBoughtViewController ()<BoughtImageDelegate>

@end

@implementation MyBoughtViewController

@synthesize btnBack,btnAdd;
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
        BoughtImageView *boughtView = [[BoughtImageView alloc] initWithFrame:CGRectMake(x, y, 90, 140)];
        [self.scrollView addSubview:boughtView];
        boughtView.delegate = self;
        boughtView.boughtImgSelectIndex = i;
        //        [boughtView setDashImageUrl:<#(NSString *)#> CategoryName:(NSString *) CategoryCost:<#(NSString *)#>];
        
    }
    UIView   *view  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 11*140)];
    self.scrollView.contentSize = view.frame.size;
}

#pragma mark - image view select method.
- (void)btnCategory_4Clicked:(int)index
{
    int selectIndex = index;
    switch (selectIndex)
    {
        case 0:
        {
           
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
    NewAdViewController     *vc = [[NewAdViewController alloc]initWithNibName:@"NewAdViewController" bundle:nil];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
