//
//  PersonInfoCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/2/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "PersonContactInfoCell.h"

@interface PersonContactInfoCell ()
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@end

@implementation PersonContactInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.text.numberOfLines = 0;
    self.text.textColor = RGB_COLOR(102., 107., 112.);

    self.title.textColor = RGB_COLOR(29., 31., 33.);

    self.icon.tintColor = kTintColor;
    self.icon.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setLabel:(NSString *const)label text:(NSString *const)text imageNamed:(NSString *const)imageName {
    self.title.text = label;
    self.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];

    self.text.text = text;
    self.text.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    self.icon.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
