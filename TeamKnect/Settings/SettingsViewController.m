//
//  SettingsViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/22/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTeamEditorViewController.h"
#import "SettingsProfile4ViewController.h"
#import "SettingsProfileViewController.h"
#import "SettingsMeasurementCell.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "Team.h"

static const NSInteger kAccountSection = 0;
static const NSInteger kTeamsSection = 1;
static const NSInteger kMeasurementSection = 2;
static const NSInteger kSocialSection = 3;

@interface SettingsViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, assign) BOOL canSendMail;
@end

@implementation SettingsViewController

- (void)loadTeams {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    request.propertiesToFetch = @[@"name"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    self.teams = [self.managedObjectContext executeFetchRequest:request error:NULL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self loadTeams];
    
    // TODO: Change this to an FRC and then we don't need notification stuff.  It's just automatic.
    [[NSNotificationCenter defaultCenter] addObserverForName:kTeamsChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self loadTeams];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kTeamsSection] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    self.canSendMail = [MFMailComposeViewController canSendMail];
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - === Table View === -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kAccountSection:
            return 2;
            
        case kMeasurementSection:
            return 1;
            
        case kTeamsSection:
            return [self.teams count] + 1;
            
        case kSocialSection:
            return 2;
            
        default:
            abort();
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;
    
    if (section != kMeasurementSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
        cell.textLabel.textColor = RGB_COLOR(0, 60, 110);
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        switch (section) {
            case kAccountSection:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                if (indexPath.row == 0)
                    cell.textLabel.text = NSLocalizedString(@"SETTINGS_ACCOUNT_PROFILE", @"The profile row in the account section");
                else
                    cell.textLabel.text = NSLocalizedString(@"SETTINGS_ACCOUNT_NOTIFICATIONS", @"The notifications row in the account section");
                
                break;
                
            case kTeamsSection: {
                if ((NSUInteger)indexPath.row == self.teams.count) {
                    cell.textLabel.text = NSLocalizedString(@"SETTINGS_CREATE_NEW_TEAM", @"Text for team label to generate a new team");
                    cell.imageView.image = [UIImage imageNamed:@"plus"];
                } else {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = ((const Team *const)self.teams[indexPath.row]).name;
                }
                
                break;
            }
                
            case kSocialSection:
                if (row == 0) {
                    cell.textLabel.text = NSLocalizedString(@"SETTINGS_CONTACT_US", @"Contact us row in the settings pane");
                    if (!self.canSendMail)
                        cell.textLabel.textColor = [UIColor grayColor];
                } else
                    cell.textLabel.text = NSLocalizedString(@"SETTINGS_SOCIAL", @"Social media row in the settings pane");
                break;
                
            default:
                abort();
                
        }
        
        return cell;
    } else {
        SettingsMeasurementCell *cell = [tableView dequeueReusableCellWithIdentifier:@"segment" forIndexPath:indexPath];
        cell.metric = IS_USING_METRIC;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger section = indexPath.section;
    const NSUInteger row = indexPath.row;

    switch (section) {
        case kAccountSection:
            [self performSegueWithIdentifier:indexPath.row == 0 ? @"settingsProfile" : @"settingsNotification" sender:nil];
            break;
        case kTeamsSection:
            if (row == self.teams.count)
                self.onTeamCreatePressed();
            else
                [self performSegueWithIdentifier:@"settingsTeamEditor" sender:self.teams[indexPath.row]];
            break;
        case kSocialSection:
            if (row == 0) {
                [self contactUs];
            } else
                [self socialMedia];
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *str;
    
    switch (section) {
        case kAccountSection:
            str = NSLocalizedString(@"SETTINGS_ACCOUNT_HEADER", @"Header for the account section in the settings table.");
            break;
        case kTeamsSection:
            str = NSLocalizedString(@"SETTINGS_MANAGE_TEAMS_HEADER", @"Header for the manage teams section in the settings table.");
            break;
        case kMeasurementSection:
            str = NSLocalizedString(@"SETTINGS_MEASUREMENT_HEADER", @"Header for the measurement section in the settings table.");
            break;
        case kSocialSection:
            str = NSLocalizedString(@"SETTINGS_SOCIAL_HEADER", @"Header for the social section in the settings table.");
            break;
        default:
            abort();
    }

    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    view.textLabel.attributedText  = [[NSAttributedString alloc] initWithString:[str uppercaseStringWithLocale:[NSLocale currentLocale]] attributes:@{NSForegroundColorAttributeName : kTintColor}];
    view.contentView.backgroundColor = RGB_COLOR(222, 228, 235);
    
    return view;
}

#pragma mark - === Social Section === -

- (void)socialMedia {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[@"TeamKnect rocks"] applicationActivities:nil];
    vc.excludedActivityTypes = @[
                                 UIActivityTypeMail, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact,
                                 UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop
                                 ];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (void)contactUs {
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;
    [vc setToRecipients:@[@"support@teamknect.com"]];
    
    const NSString *const os = [UIDevice currentDevice].systemVersion;
    
    NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
   
    [vc setMessageBody:[NSString stringWithFormat:@"\n\n\n\niOS version: %@\nApp version: %@", os, dict[@"CFBundleShortVersionString"]] isHTML:NO];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - === Segues === -

- (IBAction)returnToSettingsSegue:(UIStoryboardSegue *)sender {

}

- (IBAction)settingsProfileUpdated:(UIStoryboardSegue *)sender {
    SettingsProfile4ViewController *vc = [sender sourceViewController];
    
    Person *person = (Person *) [self.managedObjectContext objectWithID:vc.person.objectID];
    
    [[WebServer sharedInstance] updatePerson:person success:^(const NSArray *const latLng) {
        if (latLng.count == 2) {
            person.latitude = latLng[0];
            person.longitude = latLng[1];
        }
        
        [self.managedObjectContext save:NULL];
    } failure:^(NSError *error) {
        NSLog(@"%s: %@", __func__, error);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settingsProfile"]) {
        SettingsProfileViewController *vc = [segue realDestinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"settingsTeamEditor"]) {
        SettingsTeamEditorViewController *vc = [segue realDestinationViewController];
        vc.team = sender;
    }
}

@end

