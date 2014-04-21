//
//  BoughtImageView.h
//  TeamkNect
//
//  Created by lion on 4/9/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BoughtImageDelegate <NSObject>

- (void)btnCategory_4Clicked:(int)index;

@end

@interface BoughtImageView : UIView
{
    id<BoughtImageDelegate> delegate;
}

@property (strong, nonatomic) id<BoughtImageDelegate>       delegate;
@property (strong, nonatomic) IBOutlet UIImageView          *imgViewCategory_4;
@property (strong, nonatomic) IBOutlet UILabel              *lblCategoryName_4;
@property (strong, nonatomic) IBOutlet UILabel              *lblCategoryCost_4;
@property (strong, nonatomic) IBOutlet UIButton             *btnCategory_4;
@property (nonatomic)         int                           boughtImgSelectIndex;

- (void)setBoughtImageUrl:(NSString *)url CategoryName:(NSString *)catgoryName CategoryCost:(NSString *)categoryCost;

@end