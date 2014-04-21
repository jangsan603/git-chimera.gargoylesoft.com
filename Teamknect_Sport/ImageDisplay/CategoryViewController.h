//
//  CategoryViewController.h
//  TeamkNect
//
//  Created by Jangsan on 4/3/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton                     *btnBack;               //-------back button event.
@property (strong, nonatomic) IBOutlet UIButton                     *btnMsg;                //-------message button event.
@property (strong, nonatomic) IBOutlet UIButton                     *btnCommodityImg_1;     //-------commodity_1 image event.
@property (strong, nonatomic) IBOutlet UIButton                     *btnCommodityImg_2;     //-------commodity_2 image event.
//--------------(button tag index value <70 ~ 71> set).

@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewUserPhoto;      //-------user photo display.
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewStar_1;         //-------star image_1 display.
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewStar_2;         //-------star image_2 display.
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewStar_3;         //-------star image_3 display.
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewStar_4;         //-------star image_4 display.
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewStar_5;         //-------star image_5 display.
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewStar_6;         //-------star image_6 display.

@property (strong, nonatomic) IBOutlet UILabel                      *lblTitleName;          //-------title team member name.
@property (strong, nonatomic) IBOutlet UILabel                      *lblMemberName;         //-------team member name.

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnMsgClicked:(id)sender;
- (IBAction)btnCommodityImgClicked:(id)sender;

@end
