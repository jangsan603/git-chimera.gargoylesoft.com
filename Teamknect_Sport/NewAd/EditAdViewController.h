//
//  EditAdViewController.h
//  TeamkNect
//
//  Created by Jangsan on 4/4/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditAdViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton                 *btnCancel;         //------cancel button event.
@property (strong, nonatomic) IBOutlet UIButton                 *btnSave;           //------save button event.
@property (strong, nonatomic) IBOutlet UIButton                 *btnChangePrice;    //------change price button event.
@property (strong, nonatomic) IBOutlet UIImageView              *imgOldCategory;    //------old category image view.
@property (strong, nonatomic) IBOutlet UIButton                 *btnCamera;         //------camera button.
@property (strong, nonatomic) IBOutlet UILabel                  *lblCost;           //------cost label.
@property (strong, nonatomic) IBOutlet UITableView              *tblInfo;           //------category table information.

- (IBAction)btnCancelClicked:(id)sender;
- (IBAction)btnSaveClicked:(id)sender;
- (IBAction)btnChangePriceClicked:(id)sender;
- (IBAction)btnCameraClicked:(id)sender;

@end
