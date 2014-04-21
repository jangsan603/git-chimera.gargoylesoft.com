//
//  BoughtImageView.m
//  TeamkNect
//
//  Created by lion on 4/9/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import "BoughtImageView.h"

@implementation BoughtImageView

@synthesize  imgViewCategory_4, lblCategoryCost_4, lblCategoryName_4,btnCategory_4;
@synthesize  delegate = delegate;
@synthesize  boughtImgSelectIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"BoughtImageView" owner:self options:nil]objectAtIndex:0];
    [self setFrame:frame];
    if (self)
    {
        [btnCategory_4 addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
        boughtImgSelectIndex = -1;
        [self.layer setCornerRadius:5.0];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setBoughtImageUrl:(NSString *)url CategoryName:(NSString *)catgoryName CategoryCost:(NSString *)categoryCost
{
    //    [self.imgViewCategory setImage:(UIImage *)];
    //    [self.lblCategoryName setText:categoryName];
    //    [self.lblCategoryCost setText:categoryCost];
}

- (void)doneClick
{
    [delegate btnCategory_4Clicked:boughtImgSelectIndex];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
