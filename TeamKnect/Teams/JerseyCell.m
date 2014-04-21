//
//  JerseyCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/14/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "JerseyCell.h"
#import "Person+Category.h"
#import "InjuryStatus.h"
#import "TeamPerson.h"

@interface JerseyCell ()
@property (weak, nonatomic) IBOutlet UILabel *jerseyNumber;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *injuryStatus;
@end

@implementation JerseyCell

- (void)setTeamPerson:(const TeamPerson *const)teamPerson {
    const Person *const person = teamPerson.person;

    self.jerseyNumber.text = [teamPerson.jersey stringValue];
    self.name.text = [person formattedName];
    self.injuryStatus.image = [InjuryStatus imageForStatus:person.injury_status];
}

@end
