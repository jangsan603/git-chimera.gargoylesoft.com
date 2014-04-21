//
//  ImageDisplayView.h
//  TeamkNect
//
//  Created by Jangsan on 4/6/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageDisplayDelegate <NSObject>

- (void)btnCategory_3Clicked:(int)index;

@end

@interface ImageDisplayView : UIView
{
    id<ImageDisplayDelegate> delegate;
}

@property (strong, nonatomic) id <ImageDisplayDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewCategory_3;
@property (strong, nonatomic) IBOutlet UIButton                     *btnCategory_3;
@property (strong, nonatomic) IBOutlet UILabel                      *lblCategoryName_3;
@property (strong, nonatomic) IBOutlet UILabel                      *lblCategorCost_3;
@property (nonatomic)         int                                   ImgDisplaySelectIndex;

- (void)setImageDisplayUrl:(NSString *)url CategoryName:(NSString *)catgoryName CategoryCost:(NSString *)categoryCost;
@end
