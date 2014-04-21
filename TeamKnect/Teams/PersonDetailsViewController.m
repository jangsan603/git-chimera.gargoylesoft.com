//
//  PersonDetailsViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/19/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "PersonDetailsViewController.h"
#import "InjuryStatusHistoryViewController.h"
#import "PersonDetailsInfoViewController.h"
#import "PersonContactInfoViewController.h"
#import <UIImageView+AFNetworking.h>
#import "PersonDetailsProtocol.h"
#import "TeamPerson+Category.h"
#import "Person+Category.h"
#import "UIView+Category.h"
#import "InjuryStatus.h"
#import "WebServer.h"
#import "Picture.h"

@interface PersonDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *picture;
@property (weak, nonatomic) IBOutlet UIView *controllerContainmentLocationView;
@property (weak, nonatomic) IBOutlet UILabel *playerName;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *playerNumber;
@property (weak, nonatomic) IBOutlet UIButton *injuryStatusBlank;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *userButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *quickJumpButtons;

@property (nonatomic, copy) NSArray *priorConstraints;
@property (nonatomic, strong) UIButton *currentlySelectedButton;
@property (nonatomic, strong) UIViewController *bottomViewController;
@property (nonatomic, strong) UIViewController *defaultViewController;
@end

@implementation PersonDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __typeof__(self) __weak weakSelf = self;

    [[NSNotificationCenter defaultCenter] addObserverForName:kInjuryChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        __typeof__(self) __strong strongSelf = weakSelf;
        
        UIImage *const image = [InjuryStatus circledImageForStatus:note.userInfo[kInjuryChangedValue] selected:strongSelf.currentlySelectedButton == strongSelf.injuryStatusBlank];
        [strongSelf.injuryStatusBlank setImage:image forState:UIControlStateNormal];
    }];
    
    UIColor *const tintColor = kTintColor;
    for (UIButton *button in self.quickJumpButtons) {
        UIImage *image = [button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:image forState:UIControlStateNormal];
        button.imageView.tintColor = tintColor;
    }

    self.picture.layer.cornerRadius = CGRectGetWidth(self.picture.frame) / 2.;   // 1/2 the width of the image
    self.picture.layer.borderWidth = 1.;
    self.picture.layer.borderColor = [UIColor whiteColor].CGColor;
    self.picture.clipsToBounds = YES;
    self.picture.contentMode = UIViewContentModeScaleAspectFit;

    self.playerNumber.text = [self.teamPerson.jersey stringValue];

    const Person *const person = self.teamPerson.person;

    UIImage *image = [InjuryStatus circledImageForStatus:person.injury_status selected:NO];
    if (image)
        [self.injuryStatusBlank setImage:image forState:UIControlStateNormal];

    self.playerName.text = [person formattedName];

    UIButton *starter = nil;
    switch (self.startingViewController) {
        case PersonDetailsVCStartingVCChat:
            starter = self.chatButton;
            break;
            
        case PersonDetailsVCStartingVCInfo:
            starter = self.infoButton;
            break;
            
        case PersonDetailsVCStartingVCInjury:
            starter = self.injuryStatusBlank;
            break;
            
        default:
            starter = self.userButton;
            break;
    }
    
    [starter sendActionsForControlEvents:UIControlEventTouchUpInside];
          
    NSData *const png = person.thumbnail;
    if (png) {
        [self.picture setImage:[UIImage imageWithData:png] forState:UIControlStateNormal];
        return;
    }

    // TODO:  picture should have a last modified, and this should just pass the ident and date to a webservice that will return nothing or an updated picture.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pictures/%ld/%@.png", kBaseWebAppUrl, [person.sql_ident longValue] % 10l, person.sql_ident]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    UIButton __weak *weakButton = self.picture;
    [self.picture.imageView setImageWithURLRequest:request
                                  placeholderImage:[UIImage imageNamed:@"image_placeholder"]
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               UIButton __strong *strongButton = weakButton;
                                               [strongButton setImage:image forState:UIControlStateNormal];
                                               
                                               [person.managedObjectContext performBlockAndWait:^{
                                                   [person assignImage:image];
                                                   
                                                   NSError *error;
                                                   if (![person.managedObjectContext save:&error])
                                                       NSLog(@"%s: %@", __func__, error);
                                               }];
                                           } failure:nil];
    
    const BOOL isMe = [self.teamPerson.person isMe];
    self.chatButton.enabled = !isMe;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - === Tag Buttons === -

- (void)newButtonSelected:(UIButton *)button {
    self.currentlySelectedButton.imageView.tintColor = kTintColor;
    self.currentlySelectedButton = button;
    button.imageView.tintColor = [UIColor whiteColor];
    
    [self updateInjuryButtonImage];
}

- (IBAction)chatButtonPressed:(UIButton *)sender {
    if (self.currentlySelectedButton == sender)
        return;

    [self newButtonSelected:sender];

    [BlockAlertView okWithMessage:@"Like I'd chat with you!"];
}

- (IBAction)userDetailsButtonPressed:(id)sender {
    if (self.currentlySelectedButton == sender)
        return;

    [self newButtonSelected:sender];

    PersonDetailsInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"personDetailsUser"];
    vc.teamPerson = self.teamPerson;

    [self replaceBottomViewController:vc];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    if (self.currentlySelectedButton == sender)
        return;

    [self newButtonSelected:sender];

    PersonContactInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"personContactInfo"];
    vc.person = self.teamPerson.person;

    [self replaceBottomViewController:vc];
}

- (IBAction)injuryButtonPressed:(UIButton *)sender {
    if (self.currentlySelectedButton == sender)
        return;

    [self newButtonSelected:sender];
    
    InjuryStatusHistoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"injuryHistory"];
    vc.person = self.teamPerson.person;

    [self replaceBottomViewController:vc];
}

- (void)updateInjuryButtonImage {
    UIImage *const image = [InjuryStatus circledImageForStatus:self.teamPerson.person.injury_status selected:self.currentlySelectedButton == self.injuryStatusBlank];
    [self.injuryStatusBlank setImage:image forState:UIControlStateNormal];
}

#pragma mark - === View Controller Containment === -

- (void)replaceBottomViewController:(UIViewController *)newViewController {
    if (self.bottomViewController == newViewController)
        return;

    UIView *view = newViewController.view;
    view.translatesAutoresizingMaskIntoConstraints = NO;

    [self addChildViewController:newViewController];

    if (self.bottomViewController) {
        [self.bottomViewController willMoveToParentViewController:nil];
        [self transitionFromViewController:self.bottomViewController
                          toViewController:newViewController
                                  duration:0
                                   options:UIViewAnimationOptionTransitionNone
                                animations:^(void) { }    // Docs state this must not be NULL
                                completion:^(BOOL finished) {
                                    if (self.priorConstraints)
                                        [self.controllerContainmentLocationView removeConstraints:self.priorConstraints];

                                    [newViewController didMoveToParentViewController:self];

                                    [self.bottomViewController willMoveToParentViewController:nil];
                                    [self.bottomViewController removeFromParentViewController];

                                    self.bottomViewController = newViewController;

                                    self.priorConstraints = [view constrainMeToMatchSuperview:self.controllerContainmentLocationView];

                                    [(id<PersonDetailsProtocol>)self.bottomViewController setNavBars:self.navigationItem];
                                }];
    } else {
        // This will only get called once, the very first time we add a contained view controller
        [self.controllerContainmentLocationView addSubview:view];

        [newViewController didMoveToParentViewController:self];
        self.bottomViewController = newViewController;

        self.priorConstraints = [view constrainMeToMatchSuperview:self.controllerContainmentLocationView];
        
        [(id<PersonDetailsProtocol>)self.bottomViewController setNavBars:self.navigationItem];
    }
}

@end
