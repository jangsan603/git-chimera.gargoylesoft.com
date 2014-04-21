//
//  DashImageView.m
//  TeamkNect
//
//  Created by lion on 4/5/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import "DashImageView.h"

@implementation DashImageView

@synthesize  imgViewCategory_2, lblCategoryCost_2, lblCategoryName_2,btnCategory_2;
@synthesize  delegate = delegate;
@synthesize  dashImgSelectIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DashImageView" owner:self options:nil] objectAtIndex:0];
    [self setFrame:frame];
    if (self)
    {
        [btnCategory_2 addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
        dashImgSelectIndex = -1;
        [self.layer setCornerRadius:5.0];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setDashImageUrl:(NSString *)url CategoryName:(NSString *)catgoryName CategoryCost:(NSString *)categoryCost
{
    //    [self.imgViewCategory setImage:(UIImage *)];
    //    [self.lblCategoryName setText:categoryName];
    //    [self.lblCategoryCost setText:categoryCost];
}

- (void)doneClick
{
    [delegate btnCategory_2Clicked:dashImgSelectIndex];
}

@end
