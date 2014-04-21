//
//  FullImageViewController.h
//  TeamkNect
//
//  Created by lion on 4/7/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullImageViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton                 *btnBack;            //--------back button event.
@property (strong, nonatomic) IBOutlet UILabel                  *lblCategoryTitle;   //--------category title name.
@property (strong, nonatomic) IBOutlet UIImageView              *imgFullPhoto;       //--------full screen image.

- (IBAction)btnBackClicked:(id)sender;

@end
