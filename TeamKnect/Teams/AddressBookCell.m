//
//  AddressBookCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/24/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "AddressBookCell.h"

@implementation AddressBookCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.textLabel.textColor = RGB_COLOR(0, 60., 110.);
    self.textLabel.font = [UIFont systemFontOfSize:15.];

    self.detailTextLabel.textColor = RGB_COLOR(102., 107., 112.);
    self.detailTextLabel.font = [UIFont systemFontOfSize:12.];

    // Cell is still selectable, it just doesn't give the colored background.
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelectionState:(BOOL)selected {
    self.textLabel.textColor = selected ? kTintColor : RGB_COLOR(0, 60., 110.);

    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
