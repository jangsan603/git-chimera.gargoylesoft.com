//
//  TeamPerson+Category.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "TeamPerson+Category.h"

const NSInteger kPlayerRole = 0x1;
const NSInteger kCoachRole = 0x2;
const NSInteger kParentRole = 0x4;
const NSInteger kAthleticTrainerRole = 0x8;
const NSInteger kTeamDoctorRole = 0x10;
const NSInteger kTeamManagerRole = 0x20;
const NSInteger kScoutRole = 0x40;
const NSInteger kStaffRole = 0x80;
const NSInteger kFriendRole = 0x100;
const NSInteger kFamilyRole = 0x200;
const NSInteger kSponsorRole = 0x400;
const NSInteger kFanRole = 0x800;

@implementation TeamPerson (Category)

- (BOOL)hasRole:(NSInteger)role {
    return ([self.roles integerValue] & role) == role;
}

- (BOOL)hasCoachRole {
    return [self hasRole:kCoachRole];
}

- (BOOL)hasParentRole {
    return [self hasRole:kParentRole];
}

- (BOOL)hasAthleticTrainerRole {
    return [self hasRole:kAthleticTrainerRole];
}

- (BOOL)hasTeamDoctorRole {
    return [self hasRole:kTeamDoctorRole];
}

- (BOOL)hasTeamManagerRole {
    return [self hasRole:kTeamManagerRole];
}

- (BOOL)hasScoutRole {
    return [self hasRole:kScoutRole];
}

- (BOOL)isStaff {
    return [self hasAthleticTrainerRole] || [self hasTeamDoctorRole] || [self hasTeamManagerRole] || [self hasScoutRole];
}

@end
