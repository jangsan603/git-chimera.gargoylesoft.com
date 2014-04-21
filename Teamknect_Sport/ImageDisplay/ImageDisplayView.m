//
//  ImageDisplayView.m
//  TeamkNect
//
//  Created by Jangsan on 4/6/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//

#import "ImageDisplayView.h"

@implementation ImageDisplayView

@synthesize  imgViewCategory_3, btnCategory_3, lblCategorCost_3, lblCategoryName_3;
@synthesize  delegate = delegate;
@synthesize  ImgDisplaySelectIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"ImageDisplayView" owner:self options:nil]objectAtIndex:0];
    [self setFrame:frame];
    
    if (self)
    {
        [btnCategory_3 addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
        ImgDisplaySelectIndex = -1;
    }
    return self;
}

- (void)setImageDisplayUrl:(NSString *)url CategoryName:(NSString *)catgoryName CategoryCost:(NSString *)categoryCost
{
  //    [self.imgViewCategory_3 setImage:<#(UIImage *)#>];
  //    [self.lblCategoryName_3 setText:<#(NSString *)#>];
  //    [self.lblCategorCost_3 setText:<#(NSString *)#>];
}

- (void)doneClick
{
    [delegate btnCategory_3Clicked:ImgDisplaySelectIndex];
}

- (void) drawRect:(CGRect)rect
{
    [btnCategory_3 addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
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
