//
//  LeftUnderlayTableViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/10/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "LeftUnderlayTableViewController.h"
#import "NSManagedObjectContext+CoreDataImport.h"
#import "AddTeamMemberChooseRoleViewController.h"
#import "TeamCreationViewController.h"
#import "GSRevealViewController.h"
#import "TeamListViewController.h"
#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h>
#import "Team+Category.h"
#import "WebServer.h"
#import "Person.h"
#import "Sport.h"

// TODO: http://www.raywenderlich.com/23037/how-to-use-instruments-in-xcode

#define kGroupTeam   0
#define kGroupDrills 1
#define kGroupNotes  2

#define kDrillsDefense 0
#define kDrillsOffense 1
#define kDrillsGoalie  2

#define kNotesGame 0
#define kNotesRank 1
#define kNotesPractice 2

@interface LeftUnderlayTableViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) UINavigationController *homeNavController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITabBarController *tabBarController;
@end

@implementation LeftUnderlayTableViewController

extern NSString *const kLoadFullNotification;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.managedObjectContext = [[UIApplication sharedApplication].delegate performSelector:@selector(managedObjectContext)];

    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width = 100.;

    self.navigationItem.leftBarButtonItems = @[
                                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CalHome"] style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed:)],
                                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(askedToCreateNewTeam:)],
                                               spacer,
                                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonPressed)]
                                               ];

#if DEBUG
    [self.tableView setAccessibilityLabel:@"Left Navigation"];
    [self.tableView setIsAccessibilityElement:YES];
#endif
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoadFullNotification
                                                      object:nil queue:nil usingBlock:^(NSNotification *note) {
                                                          self.fetchedResultsController = nil;
                                                          [self.tableView reloadData];
                                                      }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoadFullNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - === Table View === -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
    cell.textLabel.textColor = RGB_COLOR(0, 60, 110);
    cell.imageView.image = nil;

    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;

    if (section == kGroupTeam) {
        Team *team = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = team.name;
    } else if (section == kGroupDrills) {
        if (row == kDrillsDefense)
//            cell.textLabel.text = NSLocalizedString(@"DRILLS_DEFENSE", @"Drills group, defense");
            cell.textLabel.text = [NSString stringWithFormat:@"Build #%@", [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
        else if (row == kDrillsGoalie)
            cell.textLabel.text = NSLocalizedString(@"DRILLS_GOALIE", @"Drills group, goalie");
        else if (row == kDrillsOffense)
            cell.textLabel.text = NSLocalizedString(@"DRILLS_OFFENSE", @"Drills group, offense");
    } else if (section == kGroupNotes) {
        if (row == kNotesGame)
            cell.textLabel.text = NSLocalizedString(@"NOTES_GAME", @"Notes group, game");
        else if (row == kNotesPractice) {
            cell.textLabel.text = NSLocalizedString(@"NOTES_PRACTICE", @"Notes group, practice");
            cell.imageView.image = [UIImage imageNamed:@"practice"];
        } else if (row == kNotesRank)
            cell.textLabel.text = NSLocalizedString(@"NOTES_RINK", @"Notes group, rink");
    } else {
        cell.textLabel.text = NSLocalizedString(@"SETTINGS", "Settings row in the group");
        cell.imageView.image = [UIImage imageNamed:@"setting"];
    }
    
    
#if DEBUG
    cell.accessibilityLabel = cell.textLabel.text;
    cell.isAccessibilityElement = YES;
#endif
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger section = indexPath.section;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (section == kGroupTeam) {
        self.tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"teamTabBar"];

        for (id vc in self.tabBarController.viewControllers) {
            UIViewController *root = [vc isKindOfClass:[UINavigationController class]] ? [((UINavigationController *)vc) topViewController] : vc;

            if ([root respondsToSelector:@selector(setManagedObjectContext:)])
                [root performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];

            if ([root respondsToSelector:@selector(setTeam:)])
                [root performSelector:@selector(setTeam:) withObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:GSRevealViewControllerReplaceFrontViewController object:self userInfo:@{GSRevealViewControllerReplaceFrontViewControllerKey : self.tabBarController}];
    } else if (section == kGroupDrills) {
    } else if (section == kGroupNotes) {
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kGroupTeam: {
            const NSArray *const sections = [self.fetchedResultsController sections];
            if (sections.count > 0) {
                id<NSFetchedResultsSectionInfo> info = sections[0];
                return [info numberOfObjects];
            } else
                return 0;
            break;
        }

        default:
            return 3;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *str;
    
    switch (section) {
        case kGroupTeam:
            str = [NSLocalizedString(@"TEAMS", @"Group section title for teams") uppercaseStringWithLocale:locale];
            break;
        case kGroupDrills:
            str = [NSLocalizedString(@"DRILLS", @"Group section title for drills") uppercaseStringWithLocale:locale];
            break;
        case kGroupNotes:
            str = [NSLocalizedString(@"Notes", @"Group section title for notes") uppercaseStringWithLocale:locale];
            break;

        default:
            abort();
    }

    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    view.textLabel.attributedText  = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName : kTintColor}];
    view.contentView.backgroundColor = RGB_COLOR(222, 228, 235);

    return view;
}

#pragma mark - === Fetched Results Controller === -

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil)
        return _fetchedResultsController;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                    managedObjectContext:self.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;

    NSError *error = nil;
    [_fetchedResultsController performFetch:&error];
    if (error)
        NSLog(@"%s: %@", __func__, error);

    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kGroupTeam] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - === Segues === -

- (IBAction)returnToLeftUnderlay:(UIStoryboardSegue *)sender {
    
}

- (IBAction)teamCreationCanceled:(UIStoryboardSegue *)sender {
    // TODO: Get rid of this and use returnToLeftUnderlay instead.
}

- (IBAction)teamCreationDone:(UIStoryboardSegue *)sender {
    AddTeamMemberChooseRoleViewController *vc = [sender sourceViewController];
    
    // TODO: Is this vs.MOC, or vc.team.MOC, or is it both?

    // The team hasn't been saved yet, so we have to work in the right context.
    [vc.managedObjectContext performBlock:^{
        [[WebServer sharedInstance] createTeam:vc.team success:^(const NSArray *const data) {
            // They completed all the steps, so save the MOC
            __block NSError *error;
            __block BOOL shouldReturn = NO;

            __block NSManagedObjectID *ident;

            Team *team = vc.team;

            [vc.team.managedObjectContext performBlockAndWait:^{
                team.sql_ident = data[0];
                
                [team createCalendar];

                if (![vc.team.managedObjectContext save:&error]) {
                    NSLog(@"Failed to save new team: %@", error);
                    shouldReturn = YES;
                }

                ident = team.objectID;
            }];

            if (shouldReturn)
                return;

            [self.managedObjectContext performBlock:^{
                if (![self.managedObjectContext save:&error])
                    NSLog(@"%s: %@", __func__, error);

                Team *t = (Team *) [self.managedObjectContext objectWithID:ident];

                [[WebServer sharedInstance] addPeople:vc.peopleByRole toTeam:t success:nil failure:^(NSError *error) {
                    NSLog(@"Failed to add people: %@", error);
                }];

            }];
        } failure:^(NSError *error) {
            [BlockAlertView okWithTitle:WebServerDownTitle
                                message:NSLocalizedString(@"WEB_TEAM_CREATE_FAIL", @"Message stating we couldn't create the team.")];
        }];
    }];
}

- (IBAction)askedToCreateNewTeam:(UIStoryboardSegue *)sender {
    [self performSegueWithIdentifier:@"teamCreate" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"teamCreate"]) {
        TeamCreationViewController *vc = (TeamCreationViewController *) [segue realDestinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"settings"]) {
        __typeof__(self) __weak weakSelf = self;

        SettingsViewController *vc = [segue realDestinationViewController];
        vc.onTeamCreatePressed = ^{
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                [weakSelf askedToCreateNewTeam:nil];
            }];
        };
        vc.managedObjectContext = self.managedObjectContext;
    }
}

- (IBAction)homeButtonPressed:(id)sender {
    if (!self.homeNavController)
        self.homeNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"calendarDisplayNav"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GSRevealViewControllerReplaceFrontViewController object:self userInfo:@{GSRevealViewControllerReplaceFrontViewControllerKey : self.homeNavController}];
}

- (void)settingsButtonPressed {
    [self performSegueWithIdentifier:@"settings" sender:nil];
 }

@end
