//
//  ImageDisplayViewController.h
//  TeamkNect
//
//  Created by Jangsan on 4/2/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDisplayViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton             *btnBack;           //-------back           event.
@property (strong, nonatomic) IBOutlet UIButton             *btnAdd;            //-------add            event.
@property (strong, nonatomic) IBOutlet UIButton             *btnCommodity_1;    //-------commodity_1    event.
@property (strong, nonatomic) IBOutlet UIScrollView         *scrollView;        //-------scroll view.
@property (strong, nonatomic) IBOutlet UIView               *bigView;           //-------first image view.
@property (strong, nonatomic) IBOutlet UIImageView          *imgSearch;         //-------search image view.
@property (strong, nonatomic) IBOutlet UITextField          *txtSearch;         //-------search textfield.

@property (strong, nonatomic) IBOutlet UILabel              *lblTitle;          //-------title (ex: football,...etc)

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnAddClicked:(id)sender;
- (IBAction)btnCommodityClicked:(id)sender;


@end
