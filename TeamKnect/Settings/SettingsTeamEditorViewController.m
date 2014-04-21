//
//  SettingsTeamEditorViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/23/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsTeamEditorViewController.h"
#import "AddTeamMemberChooseRoleViewController.h"
#import "SettingsCalendarColorViewController.h"
#import "SettingsTeamEditorPerson.h"
#import "Person+Category.h"
#import "Team+Category.h"
#import "AppDelegate.h"
#import "TeamPerson.h"

static const NSInteger kCalendarColorRow = 0;
static const NSInteger kLeaveTeamRow = 1;
static const NSInteger kInviteMoreRow = 2;

static const NSInteger kLeaveTeamAlert = 1;
static const NSInteger kDeleteTeamAlert = 2;

@interface SettingsTeamEditorViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, assign) BOOL lastFirst;
@property (nonatomic, assign) NSInteger teamDeleteRow;
@end

@implementation SettingsTeamEditorViewController

- (void)updateDisplay {
    const NSSortDescriptor *const joined = [NSSortDescriptor sortDescriptorWithKey:@"joined" ascending:YES];
    const NSSortDescriptor *const first = [NSSortDescriptor sortDescriptorWithKey:@"first" ascending:YES];
    const NSSortDescriptor *const last = [NSSortDescriptor sortDescriptorWithKey:@"last" ascending:YES];
    
    if (self.lastFirst)
        [self.tableData sortUsingDescriptors:@[joined, last, first]];
    else
        [self.tableData sortUsingDescriptors:@[joined, first, last]];
    
    [self.tableView reloadData];
}

- (void)addInvitesToList:(const NSArray *const)data {
    if (data.count == 0)
        return;
    
    NSMutableSet *set = [NSMutableSet setWithArray:self.tableData];
    
    for (const NSDictionary *const dict in data)
        [set addObject:[[SettingsTeamEditorPerson alloc] initWithDictionary:dict]];
    
    self.tableData = [[set allObjects] mutableCopy];
    
    [self updateDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: This should be -1 if they don't have permissions to delete a team.
    self.teamDeleteRow = 3;
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    self.navigationItem.title = self.team.name;
    
    self.lastFirst = [[[NSUserDefaults standardUserDefaults] valueForKey:@"name_preference"] isEqualToString:@"lf"];
    
    self.tableData = [[NSMutableArray alloc] init];
    
    for (const TeamPerson *const tp in self.team.people)
        [self.tableData addObject:[[SettingsTeamEditorPerson alloc] initWithPerson:tp.person]];
    
    [self updateDisplay];
    
    [[WebServer sharedInstance] getInvitedMembersForTeam:self.team
                                                 success:^(NSArray *const data) {
                                                     [self addInvitesToList:data];
                                                 } failure:nil];
    
    self.tableView.editing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
}

#pragma mark - === Table View === -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [self.tableData count];
    else
        return self.teamDeleteRow > 0 ? 4 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
    cell.textLabel.textColor = RGB_COLOR(0, 60., 110.);
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    
    if (indexPath.section == 0) {
        const SettingsTeamEditorPerson *const person = self.tableData[indexPath.row];
        
        cell.textLabel.text = [Person formattedNameWithFirst:person.first last:person.last lastFirst:self.lastFirst];
        
        if (person.joined) {
            cell.detailTextLabel.text = NSLocalizedString(@"JOINED", @"String indicating the player has joined the team");
            cell.detailTextLabel.textColor = kTintColor;
        } else {
            cell.textLabel.textColor = RGB_COLOR(171., 179., 187.);
            cell.detailTextLabel.text = NSLocalizedString(@"INVITED", @"String indicating the player has been invited to the team, but has not yet accepted");
            cell.detailTextLabel.textColor = RGB_COLOR(171., 179., 187.);
        }
    } else {
        cell.detailTextLabel.text = @"";
        
        const NSInteger row = indexPath.row;
        if (row == kCalendarColorRow)
            cell.textLabel.text = NSLocalizedString(@"TEAM_CALENDAR_COLOR", @"The label for setting the calendar color");
        else if (row == kLeaveTeamRow) {
            cell.textLabel.text = NSLocalizedString(@"TEAM_LEAVE", @"Table row text to tap when you wish to remove yourself from the team.");
            cell.imageView.image = [UIImage imageNamed:@"cross"];
        } else if (row == self.teamDeleteRow)
            cell.textLabel.text = NSLocalizedString(@"TEAM_DELETE", @"Table row text to delete this entire team.");
        else if (row == kInviteMoreRow)
            cell.textLabel.text = NSLocalizedString(@"ADD_PLAYERS_ROW", @"Text in the table row to invite more players to the team.");
        else
            abort();
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete)
        return;
    
    const SettingsTeamEditorPerson *const person = self.tableData[indexPath.row];
    [[WebServer sharedInstance] dropPlayerWithIdent:person.sql fromTeam:self.team success:^(id data) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TeamPerson"];
        request.predicate = [NSPredicate predicateWithFormat:@"person.sql_ident = %@ AND team.sql_ident = %@", person.sql, self.team.sql_ident];
        
        NSError *error = nil;
        TeamPerson *tp = [[self.team.managedObjectContext executeFetchRequest:request error:&error] firstObject];
        if (!tp) {
            NSLog(@"%s: QUERY: %@", __func__, error);
            return;
        }
        [self.team.managedObjectContext deleteObject:tp];
        
        if (![self.team.managedObjectContext save:&error])
            NSLog(@"%s: SAVE: %@", __func__, error);
        
        [self.tableData removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } failure:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kCalendarColorRow) {
        [self performSegueWithIdentifier:@"colorEdit" sender:nil];
    } else if (indexPath.row == kLeaveTeamRow) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"DROP_FROM_TEAM_CONFIRM", @"Ask for confirmation to drop from the team.")
                                                       delegate:self
                                              cancelButtonTitle:kCancelButton
                                              otherButtonTitles:kOKButton, nil];
        alert.tag = kLeaveTeamAlert;
        [alert show];
    } else if (indexPath.row == self.teamDeleteRow) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"DELETE_TEAM_CONFIRM", @"Ask for confirmation to delete the team.")
                                                       delegate:self
                                              cancelButtonTitle:kCancelButton
                                              otherButtonTitles:NSLocalizedString(@"TEAM_DELETE", @"Table row text to delete this entire team."), nil];
        alert.tag = kDeleteTeamAlert;
        [alert show];
    } else if (indexPath.row == kInviteMoreRow)
        [self performSegueWithIdentifier:@"addMembers" sender:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1)
        return UITableViewCellEditingStyleNone;
    
    const SettingsTeamEditorPerson *const person = self.tableData[indexPath.row];
    return person.joined ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1)
        return NO;
    
    const SettingsTeamEditorPerson *const person = self.tableData[indexPath.row];
    return person.joined ? YES : NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *str;
    
    if (section == 0)
        str = NSLocalizedString(@"SETTINGS_TEAM_EDITOR_MEMBERS", @"Section header for the members section");
    else
        str = NSLocalizedString(@"SETTINGS_TEAM_EDITOR_OTHER", @"Section header for the other section");
    
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    view.textLabel.attributedText  = [[NSAttributedString alloc] initWithString:[str uppercaseStringWithLocale:[NSLocale currentLocale]] attributes:@{NSForegroundColorAttributeName : kTintColor}];
    view.contentView.backgroundColor = RGB_COLOR(222, 228, 235);
    
    return view;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1)
        return indexPath;
    else
        return nil;
}

#pragma mark - === Alert View === -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex])
        return;
    
    WebResponseSuccess success = ^(id data) {
        NSError *error;
        EKCalendar *calendar = [self.team calendarForTeam];
        
        if (calendar && ![[CalendarEventStore sharedInstance] removeCalendar:calendar commit:YES error:&error])
            [BlockAlertView okWithMessage:[NSString stringWithFormat:NSLocalizedString(@"UNABLE_TO_REMOVE_CALENDAR", @"Message asking them to delete the calendar themselves"), calendar.title]];
        
        NSManagedObjectContext *ctx = self.team.managedObjectContext;
        [ctx deleteObject:self.team];
        
        if (![ctx save:&error])
            NSLog(@"Failed to drop team: %@", error);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTeamsChangedNotification object:nil];
    };
    
    if (alertView.tag == kLeaveTeamAlert) {
        const NSNumber *const me = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];
        [[WebServer sharedInstance] dropPlayerWithIdent:me fromTeam:self.team success:success failure:nil];
    } else {
        [[WebServer sharedInstance] deleteTeam:self.team success:success failure:nil];
    }
    
    [self performSegueWithIdentifier:@"returnToSettingsSegue" sender:nil];
}

#pragma mark - === Segues === -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addMembers"]) {
        AddTeamMemberChooseRoleViewController *vc = [segue realDestinationViewController];
        vc.team = self.team;
        vc.managedObjectContext = self.team.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"colorEdit"]) {
        SettingsCalendarColorViewController *vc = [segue realDestinationViewController];
        vc.initialColor = [UIColor colorWithCGColor:self.team.calendarForTeam.CGColor];
    }
}

- (IBAction)returnToSettingsTeamEditor:(UIStoryboardSegue *)sender {
    
}

// This is really "players invited" but the original VC called it this to make sense there, so I'm just keeping the name.
- (IBAction)teamCreationDone:(UIStoryboardSegue *)sender {
    AddTeamMemberChooseRoleViewController *vc = [sender sourceViewController];
    
    [[WebServer sharedInstance] addPeople:vc.peopleByRole toTeam:self.team success:^(const NSArray *const data) {
        [self addInvitesToList:data];
    } failure:^(NSError *error) {
        NSLog(@"Failed to add people: %@", error);
    }];
}

- (IBAction)calendarColorChosen:(UIStoryboardSegue *)sender {
    SettingsCalendarColorViewController *vc = [sender sourceViewController];
    
    EKCalendar *calendar = [self.team calendarForTeam];
    calendar.CGColor = vc.selectedColor.CGColor;
    
    [[CalendarEventStore sharedInstance] saveCalendar:calendar commit:YES error:NULL];
}

@end
