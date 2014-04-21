//
//  SettingsNotificationTableViewCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/12/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsNotificationTableViewCell.h"

@implementation SettingsNotificationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title.textColor = kTintColor;
}


- (IBAction)switchValueChanged:(UISwitch *)sender {
    if (self.onValueChanged)
        self.onValueChanged(sender.isOn);
}

@end
