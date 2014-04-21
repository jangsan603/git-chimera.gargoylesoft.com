//
//  MyAlertsCell.h
//  TeamkNect
//
//  Created by Jangsan on 4/9/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAlertsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView              *imgViewItem;           //--------item image(ex:new message, want item)
@property (strong, nonatomic) IBOutlet UIImageView              *imgViewDirection;      //--------direction item image.
@property (strong, nonatomic) IBOutlet UILabel                  *lblItemName;           //--------item name label.
@property (strong, nonatomic) IBOutlet UILabel                  *lblDetailName;         //--------detail name label.
@property (strong, nonatomic) IBOutlet UILabel                  *lblDate;               //--------date label.


@end
