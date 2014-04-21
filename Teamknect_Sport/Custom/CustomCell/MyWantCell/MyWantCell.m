//
//  MyWantCell.m
//  TeamkNect
//
//  Created by Jangsan on 4/9/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import "MyWantCell.h"

@implementation MyWantCell

@synthesize imgViewCheck, imgViewDirection;
@synthesize lblCategoryName, lblDetail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        lblCategoryName                     = [[UILabel alloc]initWithFrame:CGRectMake(50, 8, 150, 15)];
        lblCategoryName.textAlignment       =  NSTextAlignmentLeft;
        lblCategoryName.font                = [UIFont systemFontOfSize:15.0];
        lblCategoryName.textColor           = [UIColor colorWithRed:0 green:0.635 blue:1 alpha:1.0];
        lblCategoryName.backgroundColor     = [UIColor clearColor];
        [self.contentView addSubview:lblCategoryName];
        
        lblDetail                           = [[UILabel alloc]initWithFrame:CGRectMake(50, 28, 200, 14)];
        lblDetail.textAlignment             = NSTextAlignmentLeft;
        lblDetail.font                      = [UIFont systemFontOfSize:13.0];
        lblDetail.textColor                 = [UIColor colorWithRed:0.435 green:0.454 blue:0.474 alpha:1.0];
        lblDetail.backgroundColor           = [UIColor clearColor];
        [self.contentView addSubview:lblDetail];
        
        imgViewDirection                    = [[UIImageView alloc]initWithFrame:CGRectMake(300, 16, 8, 13)];
        [self.contentView addSubview:imgViewDirection];
        
        imgViewCheck                        = [[UIImageView alloc]initWithFrame:CGRectMake(20, 14, 22, 22)];
        [self.contentView addSubview:imgViewCheck];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
