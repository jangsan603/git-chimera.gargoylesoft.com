//
//  HomeImageView.m
//  TeamkNect
//
//  Created by lion on 4/5/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import "Global.h"
#import "HomeImageView.h"


@implementation HomeImageView

@synthesize imgViewCategory_1, lblCategoryName_1, btnCategory_1;
@synthesize delegate = delegete;
@synthesize homeImgSelectIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"HomeImageView" owner:self options:nil]objectAtIndex:0];
    [self setFrame:frame];
    if (self)
    {
        [btnCategory_1 addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
        homeImgSelectIndex = -1;
        [self.layer setCornerRadius:5.0];
        self.clipsToBounds = YES;
      
    }
    return self;
}

- (void)setHomeImageUrl:(NSString *)url CategoryName:(NSString *)categoryName
{
//    [self.imgViewCategory_1 setImage:(UIImage *)];
//    [self.lblCategoryName_1 setText:(NSString *)];
}

- (void) doneClick
{
    [delegete btnCategory_1Clicked:homeImgSelectIndex];
}

- (void) drawRect:(CGRect)rect
{
    [btnCategory_1 addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
}

@end
