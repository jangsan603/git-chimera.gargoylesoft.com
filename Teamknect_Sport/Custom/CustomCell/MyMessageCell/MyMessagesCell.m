//
//  MyMessagesCell.m
//  TeamkNect
//
//  Created by Jangsan Squires on 5/4/2014.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "MyMessagesCell.h"

@implementation MyMessagesCell

@synthesize lblName, lblDetail, lblDate;
@synthesize imgViewUser, imgViewDirection;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        lblName                     = [[UILabel alloc]initWithFrame:CGRectMake(65, 5, 120, 20)];
        lblName.textAlignment       =  NSTextAlignmentLeft;
        lblName.font                = [UIFont systemFontOfSize:15.0];
        lblName.textColor           = [UIColor colorWithRed:0 green:0.235 blue:0.431 alpha:1.0];
        lblName.backgroundColor     = [UIColor clearColor];
        [self.contentView addSubview:lblName];
        
        lblDetail                   = [[UILabel alloc]initWithFrame:CGRectMake(65, 30, 200, 20)];
        lblDetail.textAlignment     =  NSTextAlignmentLeft;
        lblDetail.font              = [UIFont systemFontOfSize:13.0];
        lblDetail.textColor         = [UIColor colorWithRed:0.4 green:0.419 blue:0.439 alpha:1.0];
        lblDetail.backgroundColor   = [UIColor clearColor];
        [self.contentView addSubview:lblDetail];
        
        lblDate                     = [[UILabel alloc]initWithFrame:CGRectMake(220, 10, 80, 13)];
        lblDate.textAlignment       = NSTextAlignmentLeft;
        lblDate.font                = [UIFont systemFontOfSize:10.0];
        lblDate.textColor           = [UIColor colorWithRed:0.670 green:0.701 blue:0.733 alpha:1.0];
        lblDate.backgroundColor     = [UIColor clearColor];
        [self.contentView addSubview:lblDate];
        
        imgViewUser                 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 45, 45)];
        [imgViewUser.layer setCornerRadius:22.0];
        imgViewUser.clipsToBounds = YES;
        [imgViewUser.layer setBorderColor:[UIColor brownColor].CGColor];
        [imgViewUser.layer setBorderWidth:1.0];
        [self.contentView addSubview:imgViewUser];
        
        imgViewDirection            = [[UIImageView alloc]initWithFrame:CGRectMake(300, 18, 8, 13)];
        [self.contentView addSubview:imgViewDirection];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
