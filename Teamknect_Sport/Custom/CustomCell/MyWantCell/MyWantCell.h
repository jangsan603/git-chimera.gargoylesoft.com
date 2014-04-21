//
//  MyWantCell.h
//  TeamkNect
//
//  Created by Jangsan on 4/9/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWantCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel               *lblCategoryName;           //--------category name label.
@property (strong, nonatomic) IBOutlet UILabel               *lblDetail;                 //--------detail explain label.
@property (strong, nonatomic) IBOutlet UIImageView           *imgViewCheck;              //--------check image.
@property (strong, nonatomic) IBOutlet UIImageView           *imgViewDirection;          //--------direction image.

@end
