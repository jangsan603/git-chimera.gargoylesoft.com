//
//  MyAlertsCell.m
//  TeamkNect
//
//  Created by Jangsan on 4/9/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import "MyAlertsCell.h"

@implementation MyAlertsCell

@synthesize imgViewItem, imgViewDirection;
@synthesize lblItemName, lblDetailName, lblDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        imgViewItem                     = [[UIImageView alloc]initWithFrame:CGRectMake(20, 17, 15, 15)];
        [self.contentView addSubview:imgViewItem];
        
        imgViewDirection                = [[UIImageView alloc]initWithFrame:CGRectMake(300, 18, 8, 13)];
        [self.contentView addSubview:imgViewDirection];
        
        lblItemName                     = [[UILabel alloc]initWithFrame:CGRectMake(45, 10, 150, 14)];
        lblItemName.textAlignment       =  NSTextAlignmentLeft;
        lblItemName.font                = [UIFont systemFontOfSize:13.0];
        lblItemName.textColor           = [UIColor colorWithRed:0 green:0.235 blue:0.431 alpha:1.0];
        lblItemName.backgroundColor     = [UIColor clearColor];
        [self.contentView addSubview:lblItemName];
        
        lblDetailName                   = [[UILabel alloc]initWithFrame:CGRectMake(45, 29, 150, 12)];
        lblDetailName.textAlignment     = NSTextAlignmentLeft;
        lblDetailName.font              = [UIFont systemFontOfSize:10.0];
        lblDetailName.textColor         = [UIColor colorWithRed:0.4 green:0.419 blue:0.439 alpha:1.0];
        lblDetailName.backgroundColor   = [UIColor clearColor];
        [self.contentView addSubview:lblDetailName];
        
        lblDate                         = [[UILabel alloc]initWithFrame:CGRectMake(220, 20, 80, 10)];
        lblDate.textAlignment           = NSTextAlignmentLeft;
        lblDate.font                    = [UIFont boldSystemFontOfSize:10.0];
        lblDate.textColor               = [UIColor colorWithRed:0.670 green:0.701 blue:0.733 alpha:1.0];
        lblDate.backgroundColor         = [UIColor clearColor];
        [self.contentView addSubview:lblDate];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
