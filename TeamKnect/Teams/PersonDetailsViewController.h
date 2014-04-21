//
//  PersonDetailsViewController.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/19/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@class TeamPerson;

typedef NS_ENUM(NSInteger, PersonDetailsVCStartingVC) {
    PersonDetailsVCStartingVCInfo,
    PersonDetailsVCStartingVCUser,
    PersonDetailsVCStartingVCChat,
    PersonDetailsVCStartingVCInjury
};

@interface PersonDetailsViewController : UIViewController

@property (nonatomic, strong) TeamPerson *teamPerson;
@property (nonatomic, assign) PersonDetailsVCStartingVC startingViewController;

@end
