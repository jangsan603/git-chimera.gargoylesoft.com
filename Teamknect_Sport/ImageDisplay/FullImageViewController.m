//
//  FullImageViewController.m
//  TeamkNect
//
//  Created by lion on 4/7/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import "FullImageViewController.h"

@interface FullImageViewController ()

@end

@implementation FullImageViewController

@synthesize btnBack, lblCategoryTitle, imgFullPhoto;

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
    [imgFullPhoto.layer setBorderColor:[UIColor whiteColor].CGColor];
    [imgFullPhoto.layer setBorderWidth:2.0];
    
}

- (IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
