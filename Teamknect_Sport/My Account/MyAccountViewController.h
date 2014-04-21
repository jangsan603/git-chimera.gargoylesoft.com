//
//  MyAccountViewController.h
//  TeamkNect
//
//  Created by Jangsan on 4/1/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface MyAccountViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton               *btnBack;         //--------back button event.
@property (strong, nonatomic) IBOutlet UIButton               *btnLogOut;       //--------log out button event.
@property (strong, nonatomic) IBOutlet UIImageView            *imgUserPhoto;    //--------user photo image.
@property (strong, nonatomic) IBOutlet UIImageView            *imgStar_1;       //--------star1 image.
@property (strong, nonatomic) IBOutlet UIImageView            *imgStar_2;       //--------star2 image.
@property (strong, nonatomic) IBOutlet UIImageView            *imgStar_3;       //--------star3 image.
@property (strong, nonatomic) IBOutlet UIImageView            *imgStar_4;       //--------star4 image.
@property (strong, nonatomic) IBOutlet UIImageView            *imgStar_5;       //--------star5 image.
@property (strong, nonatomic) IBOutlet UILabel                *lblDate;         //--------date(y/m/d)information.
@property (strong, nonatomic) IBOutlet UILabel                *lblUserName;     //--------user name.
@property (strong, nonatomic) IBOutlet UILabel                *lblWantCout;     //--------wanted item count.
@property (strong, nonatomic) IBOutlet UILabel                *lblBoughtCount;  //--------bought item count.
@property (strong, nonatomic) IBOutlet UILabel                *lblSellingCount; //--------selling item count.

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnLogOutClicked:(id)sender;


@end
