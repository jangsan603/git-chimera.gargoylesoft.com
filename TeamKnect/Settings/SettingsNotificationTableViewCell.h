//
//  SettingsNotificationTableViewCell.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/12/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@interface SettingsNotificationTableViewCell : UITableViewCell

typedef void (^SettingsNotificationBlock)(BOOL isOn);

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UISwitch *onOff;
@property (nonatomic, copy) SettingsNotificationBlock onValueChanged;

@end
