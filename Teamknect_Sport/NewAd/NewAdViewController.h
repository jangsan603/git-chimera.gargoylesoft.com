//
//  NewAdViewController.h
//  TeamkNect
//
//  Created by Jangsan on 3/30/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewAdViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton                  *btnCancel;            //-------cancel event.
@property (strong, nonatomic) IBOutlet UIButton                  *btnNext;              //-------next event.
@property (strong, nonatomic) IBOutlet UIButton                  *btnSave;              //-------save event.
@property (strong, nonatomic) IBOutlet UITextField               *txtName;              //-------name text.
@property (strong, nonatomic) IBOutlet UITextField               *txtCategory;          //-------category text.
@property (strong, nonatomic) IBOutlet UITextView                *txtViewDescription;   //-------description textview.
@property (strong, nonatomic) IBOutlet UILabel                   *lblLevel;             //-------(2/3, 3/3 level).

- (IBAction)btnCancelClicked:(id)sender;
- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnSaveClicked:(id)sender;

//-----------NewAd2 view variable.

@property (strong, nonatomic) IBOutlet UIView                    *viewNewAd2;           //-------newad2 view.
@property (strong, nonatomic) IBOutlet UIButton                  *btnNewAd2Prev;        //-------newad2 previous button event.
@property (strong, nonatomic) IBOutlet UIButton                  *btnNewAd2Next;        //-------next button event.

- (IBAction)btnNewAd2PrevClicked:(id)sender;
- (IBAction)btnNewAd2NextClicked:(id)sender;

//-----------NewAd3 view variable.

@property (strong, nonatomic) IBOutlet UIView                    *viewNewAd3;           //------newad3 view.
@property (strong, nonatomic) IBOutlet UIButton                  *btnTier;              //------change price tier button event.
@property (strong, nonatomic) IBOutlet UIButton                  *btnNewAd3Prev;        //------newad3 previous button event.
@property (strong, nonatomic) IBOutlet UILabel                   *lblPrice;             //------<$0.99> label event.

- (IBAction)btnNewAd3PrevClicked:(id)sender;
- (IBAction)btnTierClicked:(id)sender;




@end
