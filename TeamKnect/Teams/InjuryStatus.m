//
//  InjuryStatus.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/19/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "InjuryStatus.h"
#import "LocalizedStrings.h"

@implementation InjuryStatus

+ (NSString *)textForStatus:(const NSNumber *const)status {
    switch ([status integerValue]) {
        case InjuryStatusTypeAway:
            return [LocalizedStrings injuryStatusAway];
        case InjuryStatusTypeOut:
            return [LocalizedStrings injuryStatusOut];
        case InjuryStatusTypePractice:
            return [LocalizedStrings injuryStatucPractice];
        case InjuryStatusTypeOK:
            return [LocalizedStrings injuryStatusHealthy];
        default:
            return nil;
    }
}

+ (UIImage *)imageForStatus:(const NSNumber *const)status {
    switch ([status integerValue]) {
        case InjuryStatusTypeAway:
            return [UIImage imageNamed:@"dot_jersey_green_crossed"];
        case InjuryStatusTypeOut:
            return [UIImage imageNamed:@"dot_jersey_red"];
        case InjuryStatusTypePractice:
            return [UIImage imageNamed:@"dot_jersey_yellow"];
        default:
            return nil;
    }
}

+ (UIImage *)circledImageForStatus:(const NSNumber *const)status selected:(BOOL)selected {
    switch ([status integerValue]) {
        case InjuryStatusTypeAway:
            return [UIImage imageNamed:selected ? @"ic_jersey_green_crossed_active" : @"ic_jersey_green_crossed_normal"];
        case InjuryStatusTypeOut:
            return [UIImage imageNamed:selected ? @"ic_jersey_red_active" : @"ic_jersey_red_normal"];
        case InjuryStatusTypePractice:
            return [UIImage imageNamed:selected ? @"ic_jersey_yellow_active" : @"ic_jersey_yellow_normal"];
        default:
            return [UIImage imageNamed:selected ? @"ic_jersey_green_active" : @"ic_jersey_green_normal"];
    }
}

@end
