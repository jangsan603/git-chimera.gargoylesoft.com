//
//  InjuryQuickEditCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/4/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "InjuryQuickEditCell.h"
#import "InjuryStatus.h"

@interface InjuryQuickEditCell ()
@property (weak, nonatomic) IBOutlet UIButton *outButton;
@property (weak, nonatomic) IBOutlet UIButton *practiceButton;
@property (weak, nonatomic) IBOutlet UIButton *scratchButton;
@property (weak, nonatomic) IBOutlet UIButton *healthyButton;
@property (weak, nonatomic) IBOutlet UILabel *outLabel;
@property (weak, nonatomic) IBOutlet UILabel *practiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *scratchLabel;
@property (weak, nonatomic) IBOutlet UILabel *healthyLabel;
@end

@implementation InjuryQuickEditCell

- (void)awakeFromNib {
    NSLocale *locale = [NSLocale currentLocale];
    
    self.practiceLabel.font = [UIFont systemFontOfSize:11];
    self.scratchLabel.font = [UIFont systemFontOfSize:11];
    self.healthyLabel.font = [UIFont systemFontOfSize:11];
    self.outLabel.font = [UIFont systemFontOfSize:11];
    
    self.practiceLabel.text = [[InjuryStatus textForStatus:@(InjuryStatusTypePractice)] uppercaseStringWithLocale:locale];
    self.scratchLabel.text = [[InjuryStatus textForStatus:@(InjuryStatusTypeAway)] uppercaseStringWithLocale:locale];
    self.healthyLabel.text = [[InjuryStatus textForStatus:@(InjuryStatusTypeOK)] uppercaseStringWithLocale:locale];
    self.outLabel.text = [[InjuryStatus textForStatus:@(InjuryStatusTypeOut)] uppercaseStringWithLocale:locale];
    
    [self.practiceButton setImage:[InjuryStatus imageForStatus:@(InjuryStatusTypePractice)] forState:UIControlStateNormal];
    [self.scratchButton setImage:[InjuryStatus imageForStatus:@(InjuryStatusTypeAway)] forState:UIControlStateNormal];
    [self.outButton setImage:[InjuryStatus imageForStatus:@(InjuryStatusTypeOut)] forState:UIControlStateNormal];
    
    // The InjuryStatus thing doesn't return a green image because normally we don't want to show it.
    [self.healthyButton setImage:[UIImage imageNamed:@"dot_jersey_green"] forState:UIControlStateNormal];
    
    [self.outButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.practiceButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.scratchButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.healthyButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)buttonSelected:(UIButton *)sender {
    if (self.onQuickEditSelected == nil)
        return;
    
    if (sender == self.outButton)
        self.onQuickEditSelected(InjuryStatusTypeOut);
    else if (sender == self.practiceButton)
        self.onQuickEditSelected(InjuryStatusTypePractice);
    else if (sender == self.scratchButton)
        self.onQuickEditSelected(InjuryStatusTypeAway);
    else
        self.onQuickEditSelected(InjuryStatusTypeOK);
}

@end
