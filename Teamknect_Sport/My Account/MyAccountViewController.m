//
//  MyAccountViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/1/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import "MyAccountViewController.h"


@interface MyAccountViewController ()

@end

@implementation MyAccountViewController

@synthesize btnBack, btnLogOut;
@synthesize imgStar_1, imgStar_2, imgStar_3, imgStar_4, imgStar_5, imgUserPhoto;
@synthesize lblUserName, lblDate, lblWantCout, lblBoughtCount, lblSellingCount;

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

- (IBAction)btnBackClicked:(id)sender
{
    [self.revealViewController revealToggleAnimated:YES];
}

- (IBAction)btnLogOutClicked:(id)sender
{
//        SWRevealViewController *revealController = self.revealViewController;
//        UINavigationController *frontNavigationController = (id)revealController.frontViewController;
//    
//        if ( ![frontNavigationController.topViewController isKindOfClass:[SignInViewController class]] )
//        {
//            SignInViewController *vc                         = [[SignInViewController alloc] init];
//            UINavigationController *navigationController   = [[UINavigationController alloc] initWithRootViewController:vc];
//            [self presentViewController:navigationController animated:YES completion:nil];
//        }
//        else
//        {
//            [revealController revealToggle:self];
//        }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
