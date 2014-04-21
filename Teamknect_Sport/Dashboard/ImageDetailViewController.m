//
//  ImageDetailViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/9/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "EditAdViewController.h"

@interface ImageDetailViewController ()

@end

@implementation ImageDetailViewController

@synthesize btnBack, btnEdit;
@synthesize lblTitle, lblCost;
@synthesize txtViewDetail;

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

- (IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnEditClicked:(id)sender
{
    EditAdViewController *vc = [[EditAdViewController alloc]initWithNibName:@"EditAdViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
