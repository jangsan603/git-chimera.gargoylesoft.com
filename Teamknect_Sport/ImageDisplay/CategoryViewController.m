//
//  CategoryViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/3/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import "Global.h"
#import "CategoryViewController.h"
#import "SendMessageViewController.h"


@interface CategoryViewController ()

@end

@implementation CategoryViewController

@synthesize btnBack, btnMsg, btnCommodityImg_1, btnCommodityImg_2;
@synthesize imgViewUserPhoto, imgViewStar_1, imgViewStar_2, imgViewStar_3, imgViewStar_4, imgViewStar_5, imgViewStar_6;
@synthesize lblMemberName, lblTitleName;

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
    [imgViewUserPhoto.layer setBorderColor:[UIColor brownColor].CGColor];
    [imgViewUserPhoto.layer setBorderWidth:1.0];
    [imgViewUserPhoto.layer setCornerRadius:5.0];
    imgViewUserPhoto.clipsToBounds = YES;
    if (globalSelectDetailImgIndex == 60)
    {
        lblTitleName.text   = @"Miriam N";
        lblMemberName.text  = @"Miriam N";
    }
    if (globalSelectDetailImgIndex == 61)
    {
        lblTitleName.text   = @"Mars S";
        lblMemberName.text  = @"Mars S";
    }
    if (globalSelectDetailImgIndex == 62)
    {
        lblTitleName.text   = @"Jack wo";
        lblMemberName.text  = @"Jack wo";
    }
    if (globalSelectDetailImgIndex == 63)
    {
        lblTitleName.text   = @"Man bo";
        lblMemberName.text  = @"Man bo";
    }
    if (globalSelectDetailImgIndex == 64)
    {
        lblTitleName.text   = @"Hong mi";
        lblMemberName.text  = @"Hong mi";
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnMsgClicked:(id)sender
{
    SendMessageViewController *vc = [[SendMessageViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnCommodityImgClicked:(id)sender
{
    UIButton *button                = (UIButton *)sender;
    globalSelectDetailImgIndex_1    = button.tag;
    
    switch (globalSelectDetailImgIndex_1)
    {
        case 70:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 71:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
