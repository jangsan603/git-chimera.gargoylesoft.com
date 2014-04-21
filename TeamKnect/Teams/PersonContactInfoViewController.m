//
//  PersonContactInfoViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/2/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "PersonContactInfoViewController.h"
#import "AppleMapViewController.h"
#import "PersonContactInfoCell.h"
#import <MessageUI/MessageUI.h>
#import "Person.h"

static const NSInteger kSectionPlayer = 0;
static const NSInteger kSectionParents = 1;
static const NSInteger kSectionRoomies = 2;

@interface PersonContactInfoViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation PersonContactInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification
                                                      object:nil queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self.tableView reloadData];
                                                  }];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)setNavBars:(UINavigationItem *)nav {
    nav.leftBarButtonItem = nil;
    nav.rightBarButtonItem = nil;
}

#pragma mark - === Table View === -

- (void)configureCell:(PersonContactInfoCell *)cell forIndexPath:(const NSIndexPath *const)indexPath {
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;

    if (section == kSectionParents) {

    } else if (section == kSectionRoomies) {

    } else if (section == kSectionPlayer) {
        if (row == 0)
            [cell setLabel:NSLocalizedString(@"PERSON_CONTACT_EMAIL_LABEL", @"Header for the person's email address")
                      text:self.person.email imageNamed:@"ic_mail"];
        else if (row == 1)
            [cell setLabel:NSLocalizedString(@"PERSON_CONTACT_PHONE_LABEL", @"Header for the person's phone number")
                      text:self.person.phone imageNamed:@"phone"];
        else if (row == 2)
            [cell setLabel:NSLocalizedString(@"PERSON_CONTACT_HOME_LABEL", @"Header for the person's home address")
                      text:self.person.address imageNamed:@"locationPin"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonContactInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal"];

    [self configureCell:cell forIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;

    if (section == kSectionParents) {

    } else if (section == kSectionRoomies) {

    } else if (section == kSectionPlayer) {
        if (row == 0) {
            if (!([MFMailComposeViewController canSendMail] && self.person.email))
                return;

            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            [vc setToRecipients:@[self.person.email]];
            vc.mailComposeDelegate = self;

            [self presentViewController:vc animated:YES completion:nil];
        } else if (row == 1) {
            if (!self.person.phone)
                return;

            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.person.phone]];
            [[UIApplication sharedApplication] openURL:url];
        } else if (row == 2) {
            [self performSegueWithIdentifier:@"showMap" sender:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static PersonContactInfoCell *cell;
    if (cell == nil)
        cell = [tableView dequeueReusableCellWithIdentifier:@"normal"];

    [self configureCell:cell forIndexPath:indexPath];
    [cell layoutIfNeeded];

    // This causes Auto Layout to reevaluate all the constraints on the cell.  We add 1 for the height
    // of the separator line and then return that size.
    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kSectionPlayer)
        return 3;
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *str;
    
    switch (section) {
        case kSectionParents:
            str = NSLocalizedString(@"PLAYER_CONTACT_PARENTS_HEADER", @"Section header for the parents group.");
            break;
            
        case kSectionPlayer:
            str = NSLocalizedString(@"PLAYER_CONTACT_PLAYER_HEADER", @"Section header for the player group");
            break;
            
        case kSectionRoomies:
            str = NSLocalizedString(@"PLAYER_CONTACT_ROOMIES_HEADER", @"Section header for the roommates and billet family");
            break;
            
        default:
            abort();
    }
    
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    view.textLabel.attributedText  = [[NSAttributedString alloc] initWithString:[str uppercaseStringWithLocale:locale] attributes:@{NSForegroundColorAttributeName : kTintColor}];
    view.contentView.backgroundColor = RGB_COLOR(222, 228, 235);
    
    return view;
}

#pragma mark - === Mail Composition === -

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - === Segues === -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMap"]) {
        AppleMapViewController *vc = [segue realDestinationViewController];
        vc.person = self.person;
    }
}

- (IBAction)closedMapFromPersonContactInfo:(UIStoryboardSegue *)sender {

}

@end
