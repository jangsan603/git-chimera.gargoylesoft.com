//
//  SettingsMeasurementCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/22/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsMeasurementCell.h"

static const NSInteger kMetricIndex = 0;
static const NSInteger kImperialIndex = 1;

@interface SettingsMeasurementCell ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@end

@implementation SettingsMeasurementCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.segment removeAllSegments];
    [self.segment insertSegmentWithTitle:NSLocalizedString(@"SETTING_SEGMENT_METRIC", @"The metric choice for measurement") atIndex:kMetricIndex animated:NO];
    [self.segment insertSegmentWithTitle:NSLocalizedString(@"SETTING_SEGMENT_IMPERIAL", @"The imperial choice for measurement") atIndex:kImperialIndex animated:NO];
    
    [self.segment addTarget:self action:@selector(selected) forControlEvents:UIControlEventValueChanged];
}

- (void)selected {
    [[NSUserDefaults standardUserDefaults] setValue:self.segment.selectedSegmentIndex == kMetricIndex ? @"metric" : @"imperial" forKey:@"unit_preference"];

    [[NSNotificationCenter defaultCenter] postNotificationName:kMeasurementTypeChangedNotification object:nil];
}

- (BOOL)isMetric {
    return self.segment.selectedSegmentIndex == kMetricIndex;
}

- (void)setMetric:(BOOL)metric {
    self.segment.selectedSegmentIndex = metric ? kMetricIndex : kImperialIndex;
}

@end
