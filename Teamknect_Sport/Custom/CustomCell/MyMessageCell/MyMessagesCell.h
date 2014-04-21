//
//  MyMessagesCell.h
//  TeamkNect
//
//  Created by Jangsan Squires on 5/4/2014.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMessagesCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel                      *lblName;           //-------team member name.
@property (strong, nonatomic) IBOutlet UILabel                      *lblDetail;         //-------detail explain.
@property (strong, nonatomic) IBOutlet UILabel                      *lblDate;           //-------date label.
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewUser;       //-------user image.
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewDirection;  //-------direction image.

@end
