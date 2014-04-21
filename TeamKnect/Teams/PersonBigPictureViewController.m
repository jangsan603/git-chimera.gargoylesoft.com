//
//  PersonBigPictureViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 4/17/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "PersonBigPictureViewController.h"
#import "PersonDetailsViewController.h"
#import "TeamPerson+Category.h"
#import "Person+Category.h"
#import "InjuryStatus.h"
#import "Picture.h"

@interface PersonBigPictureViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *cardImage;
@property (weak, nonatomic) IBOutlet UIImageView *playerImage;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *playerNumber;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *injuryButton;
@property (nonatomic, strong) UIButton *currentlySelectedButton;
@end

@implementation PersonBigPictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIColor *const tintColor = kTintColor;
    
    self.cardImage.contentMode = UIViewContentModeBottom;
    self.playerImage.contentMode = UIViewContentModeScaleAspectFill;
    self.playerImage.clipsToBounds = YES;
        
    const Person *const person = self.teamPerson.person;
    
    self.position.textColor = tintColor;
    self.position.text = self.teamPerson.position;
    
    self.name.textColor = [UIColor whiteColor];
    self.name.text = [person formattedName];
    
    self.playerNumber.textAlignment = NSTextAlignmentCenter;
    self.playerNumber.textColor = [UIColor whiteColor];
    self.playerNumber.text = [self.teamPerson.jersey stringValue];
    
    self.playerImage.image = [UIImage imageWithData:person.picture.image];
    
    for (UIButton *button in @[self.userButton, self.infoButton, self.chatButton, self.infoButton]) {
        UIImage *image = [button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:image forState:UIControlStateNormal];
        button.imageView.tintColor = tintColor;
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button addTarget:self action:@selector(newButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    __typeof__(self) __weak weakSelf = self;

    [[NSNotificationCenter defaultCenter] addObserverForName:kInjuryChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        __typeof__(self) __strong strongSelf = weakSelf;
        
        UIImage *const image = [InjuryStatus circledImageForStatus:note.userInfo[kInjuryChangedValue] selected:strongSelf.currentlySelectedButton == strongSelf.injuryButton];
        [strongSelf.injuryButton setImage:image forState:UIControlStateNormal];
    }];
    
    UIImage *const image = [InjuryStatus circledImageForStatus:self.teamPerson.person.injury_status selected:self.currentlySelectedButton == self.injuryButton];
    [self.injuryButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - === Buttons === -

- (void)newButtonSelected:(UIButton *)button {
    self.currentlySelectedButton.imageView.tintColor = kTintColor;
    self.currentlySelectedButton = button;
    button.imageView.tintColor = [UIColor whiteColor];
    [self performSegueWithIdentifier:@"gotoPersonDetails" sender:button];
}

#pragma mark - === Segues === -

- (IBAction)returnToBigPicture:(UIStoryboardSegue *)sender {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"gotoPersonDetails"]) {
        PersonDetailsViewController *vc = [segue realDestinationViewController];
        vc.teamPerson = self.teamPerson;
        
        const UIButton *const chosen = (const UIButton *const)sender;
        if (chosen == self.chatButton)
            vc.startingViewController = PersonDetailsVCStartingVCChat;
        else if (chosen == self.infoButton)
            vc.startingViewController = PersonDetailsVCStartingVCInfo;
        else if (chosen == self.injuryButton)
            vc.startingViewController = PersonDetailsVCStartingVCInjury;
        else
            vc.startingViewController = PersonDetailsVCStartingVCUser;
    }
}



@end
