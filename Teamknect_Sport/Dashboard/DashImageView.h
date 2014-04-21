//
//  DashImageView.h
//  TeamkNect
//
//  Created by lion on 4/5/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DashImageDelegate <NSObject>

- (void)btnCategory_2Clicked:(int)index;

@end

@interface DashImageView : UIView
{
    id<DashImageDelegate> delegate;
}

@property (strong, nonatomic) id<DashImageDelegate>         delegate;
@property (strong, nonatomic) IBOutlet UIImageView          *imgViewCategory_2;
@property (strong, nonatomic) IBOutlet UILabel              *lblCategoryName_2;
@property (strong, nonatomic) IBOutlet UILabel              *lblCategoryCost_2;
@property (strong, nonatomic) IBOutlet UIButton             *btnCategory_2;
@property (nonatomic)         int                           dashImgSelectIndex;

- (void)setDashImageUrl:(NSString *)url CategoryName:(NSString *)catgoryName CategoryCost:(NSString *)categoryCost;

@end
