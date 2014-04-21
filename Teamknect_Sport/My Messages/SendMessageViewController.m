//
//  SendMessageViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/3/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import "Global.h"
#import "SendMessageViewController.h"

@interface SendMessageViewController ()

@end

@implementation SendMessageViewController

@synthesize btnBack, btnSend;
@synthesize lblName;
@synthesize txtViewMsgContent;

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
    
    if (globalSelectDetailImgIndex == 60)
            lblName.text = @"Miriam N";
    if (globalSelectDetailImgIndex == 61)
            lblName.text = @"Mars S";
    if (globalSelectDetailImgIndex == 62)
            lblName.text = @"Jack wo";
    if (globalSelectDetailImgIndex == 63)
            lblName.text = @"Man bo";
    if (globalSelectDetailImgIndex == 64)
            lblName.text = @"Hong mi";
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSendClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
