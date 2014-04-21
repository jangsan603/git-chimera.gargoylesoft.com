//
//  TypeOfPersonSegmentControl.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/31/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "TypeOfPersonSegmentControl.h"

@implementation TypeOfPersonSegmentControl

+ (NSInteger)numSegments {
    return 3;
}

- (void)awakeFromNib {
    [self removeAllSegments];

    [self insertSegmentWithTitle:NSLocalizedString(@"TAB_TEAM_PLAYERS", @"The players tab when inside a team") atIndex:kPersonSegmentPerson animated:NO];
    [self insertSegmentWithTitle:NSLocalizedString(@"TAB_TEAM_COACH_STAFF", @"The coaches/staff tab when inside a team") atIndex:kPersonSegmentCoach animated:NO];
    [self insertSegmentWithTitle:NSLocalizedString(@"TAB_TEAM_FANS", @"The fans tab when inside a team") atIndex:kPersonSegmentParent animated:NO];

    [self setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];

    self.selectedSegmentIndex = 0;
}

@end
