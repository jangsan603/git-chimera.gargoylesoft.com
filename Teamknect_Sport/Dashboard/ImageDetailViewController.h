//
//  ImageDetailViewController.h
//  TeamkNect
//
//  Created by lion on 4/9/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDetailViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton             *btnBack;           //--------back button event.
@property (strong, nonatomic) IBOutlet UIButton             *btnEdit;           //--------edit button event.
@property (strong, nonatomic) IBOutlet UILabel              *lblTitle;          //--------category title label.
@property (strong, nonatomic) IBOutlet UILabel              *lblCost;           //--------category cost label.
@property (strong, nonatomic) IBOutlet UITextView           *txtViewDetail;     //--------detail explain text.

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnEditClicked:(id)sender;

@end
