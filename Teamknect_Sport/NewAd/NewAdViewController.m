//
//  NewAdViewController.m
//  TeamkNect
//
//  Created by Jangsan on 3/30/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//

#import "NewAdViewController.h"

@interface NewAdViewController ()

@end

@implementation NewAdViewController

//--------newad variable.
@synthesize btnCancel, btnNext, btnSave;
@synthesize txtCategory, txtName;
@synthesize txtViewDescription;
@synthesize lblLevel;

//--------newad2 variable.
@synthesize viewNewAd2;
@synthesize btnNewAd2Next, btnNewAd2Prev;

//--------newad3 variable.
@synthesize viewNewAd3;
@synthesize btnNewAd3Prev, btnTier;
@synthesize lblPrice;

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
    btnSave.hidden = YES;
    [self hiddenView];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - newad event.
- (IBAction)btnCancelClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnNextClicked:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.001];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    viewNewAd2.frame   = CGRectMake(0, viewNewAd2.frame.origin.y, viewNewAd2.frame.size.width, viewNewAd2.frame.size.height);
    viewNewAd3.frame   = CGRectMake(320, viewNewAd3.frame.origin.y, viewNewAd3.frame.size.width, viewNewAd3.frame.size.height);
    
    [self.view addSubview:viewNewAd2];
    [UIView commitAnimations];
    lblLevel.text      = @"2/3";
}

- (IBAction)btnSaveClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - newad2 event.
- (IBAction)btnNewAd2PrevClicked:(id)sender
{
   [self hiddenView];
   lblLevel.text      = @"1/3";
}

- (IBAction)btnNewAd2NextClicked:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.001];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    viewNewAd2.frame   = CGRectMake(320, viewNewAd2.frame.origin.y, viewNewAd2.frame.size.width, viewNewAd2.frame.size.height);
    viewNewAd3.frame   = CGRectMake(0, viewNewAd3.frame.origin.y, viewNewAd3.frame.size.width, viewNewAd3.frame.size.height);
    
    [self.view addSubview:viewNewAd3];
    [UIView commitAnimations];
    lblLevel.text      = @"3/3";
    btnSave.hidden     = NO;
}

#pragma mark - newad3 event.
- (IBAction)btnNewAd3PrevClicked:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.001];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    viewNewAd2.frame   = CGRectMake(0, viewNewAd2.frame.origin.y, viewNewAd2.frame.size.width, viewNewAd2.frame.size.height);
    viewNewAd3.frame   = CGRectMake(320, viewNewAd3.frame.origin.y, viewNewAd3.frame.size.width, viewNewAd3.frame.size.height);
    
    [self.view addSubview:viewNewAd2];
    [UIView commitAnimations];
    lblLevel.text      = @"2/3";
}

- (IBAction)btnTierClicked:(id)sender
{
    
}

#pragma mark - hidden view(newad2 and newad3).
- (void)hiddenView
{
    viewNewAd2.frame   = CGRectMake(320, viewNewAd2.frame.origin.y, viewNewAd2.frame.size.width, viewNewAd2.frame.size.height);
    viewNewAd3.frame   = CGRectMake(320, viewNewAd3.frame.origin.y, viewNewAd3.frame.size.width, viewNewAd3.frame.size.height);
}

#pragma mark - UITextFieldDelegate method.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtName     resignFirstResponder];
    [txtCategory resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
