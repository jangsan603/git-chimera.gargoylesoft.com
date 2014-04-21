//
//  ImageDisplayViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/2/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import "Global.h"
#import "ImageDisplayViewController.h"
#import "ImageExplainViewController.h"
#import "HomeViewController.h"
#import "NewAdViewController.h"
#import "ImageDisplayView.h"


@interface ImageDisplayViewController ()<ImageDisplayDelegate>

@end

@implementation ImageDisplayViewController

@synthesize btnAdd, btnBack;
@synthesize btnCommodity_1;
@synthesize lblTitle;
@synthesize scrollView, bigView, imgSearch;
@synthesize txtSearch;

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
    CGFloat startY      = 190;
    for (int i = 0; i<30; i++)
    {
        int row         = i/3;
        int column      = i%3;
        CGFloat      x  =  startX + column * (width +margin);
        CGFloat      y  =  startY + row  * (height + margin);
        
//        UIImage *img  = [UIImage imageNamed:@"4.jpg"];
//        CGFloat sizeX = img.size.width;
//        CGFloat sizeY = img.size.height;
//        CGFloat ratio = sizeY/sizeX;
//        NSLog(@"sizeX: %f,sizeY: %f, ratio:%f ", sizeX, sizeY, ratio);
       
        ImageDisplayView *displayView = [[ImageDisplayView alloc] initWithFrame:CGRectMake(x, y, 90, 140)];
        
        [self.scrollView addSubview:displayView];
        displayView.delegate = self;
        displayView.ImgDisplaySelectIndex = i;
        //        [dashView setDashImageUrl:<#(NSString *)#> CategoryName:(NSString *) CategoryCost:<#(NSString *)#>];
        
    }
    UIView   *view  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 10*140)];
    self.scrollView.contentSize = view.frame.size;
    
    
    if (globalSelectImgViewIndex == 1)
    {
        lblTitle.text = @"Football";
    }
    if (globalSelectImgViewIndex == 2)
    {
        lblTitle.text = @"Tennis";
    }
    if (globalSelectImgViewIndex == 3)
    {
        lblTitle.text = @"Soccer";
    }
    if (globalSelectImgViewIndex == 4)
    {
        lblTitle.text = @"Golf";
    }
    if (globalSelectImgViewIndex == 5)
    {
        lblTitle.text = @"Basketball";
    }
    [self.bigView.layer setCornerRadius:5.0f];
    self.bigView.clipsToBounds = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)btnCategory_3Clicked:(int)index
{
    int selectIndex = index;
    switch (selectIndex)
    {
        case 0:
            
            break;
            
        default:
            break;
    }
}

- (IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnAddClicked:(id)sender
{
    NewAdViewController *vc = [[NewAdViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)btnCommodityClicked:(id)sender
{
    UIButton *button            = (UIButton *)sender;
    globalSelectDetailImgIndex  = button.tag;
    
    switch (globalSelectDetailImgIndex)
    {
        case 60:
        {
            [self imageExplain];
        }
            break;
        case 61:
        {
            [self imageExplain];
        }
            break;
        case 62:
        {
            [self imageExplain];
        }
            break;
        case 63:
        {
            [self imageExplain];
        }
            break;
        case 64:
        {
            [self imageExplain];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)imageExplain
{
    ImageExplainViewController *vc = [[ImageExplainViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma  mark - UITextFieldDelegate method.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    imgSearch.hidden = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.scrollView endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtSearch    resignFirstResponder];
    if ([txtSearch.text isEqualToString:@""])
        imgSearch.hidden = NO;
  
    if (![txtSearch.text isEqualToString:@""])
        imgSearch.hidden = YES;

    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
