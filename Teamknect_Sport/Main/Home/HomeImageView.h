//
//  HomeImageView.h
//  TeamkNect
//
//  Created by lion on 4/5/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeImageDelegate <NSObject>

- (void)btnCategory_1Clicked:(int)index;

@end

@interface HomeImageView : UIView
{
    id <HomeImageDelegate> delegete;
}

@property (strong, nonatomic) id <HomeImageDelegate>                delegate;
@property (strong, nonatomic) IBOutlet UIImageView                  *imgViewCategory_1;
@property (strong, nonatomic) IBOutlet UILabel                      *lblCategoryName_1;
@property (strong, nonatomic) IBOutlet UIButton                     *btnCategory_1;
@property (nonatomic)         int                                   homeImgSelectIndex;

- (void)setHomeImageUrl:(NSString *)url CategoryName:(NSString *)categoryName;

@end
