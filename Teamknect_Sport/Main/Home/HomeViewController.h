//
//  HomeViewController.h
//  TeamkNect
//
//  Created by Jangsan on 3/30/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface HomeViewController : UIViewController
{
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic) IBOutlet UIButton                  *btnMenu;      //-------menu event.
@property (strong, nonatomic) IBOutlet UIButton                  *btnAdd;       //-------add event.
@property (strong, nonatomic) IBOutlet UIScrollView              *scrollView;   //-------scroll view.


- (IBAction)btnMenuClicked:(id)sender;
- (IBAction)btnAddClicked:(id)sender;
//--------------(button tag index value <0 ~ 5> set).

//--------------8 image view

@property (strong, nonatomic) IBOutlet UIView                    *viewCategory_1;
@property (strong, nonatomic) IBOutlet UIView                    *viewCategory_2;
@property (strong, nonatomic) IBOutlet UIView                    *viewCategory_3;
@property (strong, nonatomic) IBOutlet UIImageView               *imgCategoryView_1;
@property (strong, nonatomic) IBOutlet UIImageView               *imgCategoryView_2;
@property (strong, nonatomic) IBOutlet UIImageView               *imgCategoryView_3;
@property (strong, nonatomic) IBOutlet UIImageView               *imgCategoryView_4;
@property (strong, nonatomic) IBOutlet UIImageView               *imgCategoryView_5;
@property (strong, nonatomic) IBOutlet UIImageView               *imgCategoryView_6;
@property (strong, nonatomic) IBOutlet UIImageView               *imgCategoryView_7;
@property (strong, nonatomic) IBOutlet UIImageView               *imgCategoryView_8;
@property (strong, nonatomic) IBOutlet UIImageView               *imgCategoryView_9;



@end
