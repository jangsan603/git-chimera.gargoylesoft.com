//
//  TeamPerson+Category.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "TeamPerson.h"


extern const NSInteger kPlayerRole;
extern const NSInteger kCoachRole;
extern const NSInteger kParentRole;
extern const NSInteger kAthleticTrainerRole;
extern const NSInteger kTeamDoctorRole;
extern const NSInteger kTeamManagerRole;
extern const NSInteger kScoutRole;
extern const NSInteger kStaffRole;
extern const NSInteger kFriendRole;
extern const NSInteger kFamilyRole;
extern const NSInteger kSponsorRole;
extern const NSInteger kFanRole;

@interface TeamPerson (Category)

- (BOOL)hasCoachRole;
- (BOOL)hasParentRole;
- (BOOL)hasAthleticTrainerRole;
- (BOOL)hasTeamDoctorRole;
- (BOOL)hasTeamManagerRole;
- (BOOL)hasScoutRole;
- (BOOL)isStaff;

@end
