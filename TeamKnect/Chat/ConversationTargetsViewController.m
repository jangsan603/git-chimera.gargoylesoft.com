//
//  ConversationTargetsViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/8/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "ConversationTargetsViewController.h"
#import "TeamPerson+Category.h"
#import "Person+Category.h"
#import "WebServer.h"
#import "Team.h"

@interface ConversationTargetsViewController ()
@property (nonatomic, strong) NSIndexPath *selectedContact;
@property (nonatomic, copy) NSArray *teamList;
@property (nonatomic, copy) NSArray *peopleList;
@property (nonatomic, strong) NSDictionary *teamPeople;
@end

@implementation ConversationTargetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    request.propertiesToFetch = @[@"name", @"sql_ident"];
    request.relationshipKeyPathsForPrefetching = @[@"people.sql_ident"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

    self.teamList = [self.managedObjectContext executeFetchRequest:request error:NULL];

    const NSArray *const sqlIdents = [[[self.teamList valueForKeyPath:@"people.sql_ident"] firstObject] allObjects];

    request = [[NSFetchRequest alloc] initWithEntityName:@"TeamPerson"];
    request.predicate = [NSPredicate predicateWithFormat:@"sql_ident IN %@ AND person.sql_ident = %@", sqlIdents, [[NSUserDefaults standardUserDefaults] valueForKey:@"me"]];
    request.relationshipKeyPathsForPrefetching = @[@"person.sql_ident", @"team.sql_ident"];
    request.propertiesToFetch = @[@"roles"];

    const NSArray *const ary = [self.managedObjectContext executeFetchRequest:request error:NULL];

    NSMutableDictionary *teamPerson = [NSMutableDictionary new];
    for (const TeamPerson *const tp in ary)
        teamPerson[tp.team.sql_ident] = tp;

    const NSSortDescriptor *const first = [NSSortDescriptor sortDescriptorWithKey:@"first" ascending:YES];
    const NSSortDescriptor *const last = [NSSortDescriptor sortDescriptorWithKey:@"last" ascending:YES];

    request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    request.propertiesToFetch = @[@"first", @"last", @"sql_ident"];

    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"name_preference"] isEqualToString:@"lf"])
        request.sortDescriptors = @[last, first];
    else
        request.sortDescriptors = @[first, last];

    self.peopleList = [self.managedObjectContext executeFetchRequest:request error:NULL];
}

#pragma mark - === Table View === -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.teamList count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((NSUInteger)section < self.teamList.count) {
        const Team *const team = self.teamList[section];
        const TeamPerson *const tp = self.teamPeople[team.sql_ident];

        NSInteger num = 1;

        if ([tp hasCoachRole])
            num++;

        if ([tp isStaff])
            num++;

        return num;
    } else {
        return self.peopleList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];

    if ((NSUInteger)indexPath.section < self.teamList.count) {
        const NSInteger row = indexPath.row;

        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"ALL_PLAYERS_ROW", @"Text for table row specifying to chat with all players. ");
            return cell;
        }

        const Team *const team = self.teamList[indexPath.section];
        const TeamPerson *const tp = self.teamPeople[team.sql_ident];

        NSString *const coachStr = NSLocalizedString(@"ALL_COACHES_ROW", @"Text for table row specifying to chat with all players.");
        NSString *const staffStr = NSLocalizedString(@"ALL_STAFF_ROW", @"Text for table row specifying to chat with all players.");

        if (row == 1) {
            cell.textLabel.text = [tp hasCoachRole] ? coachStr : staffStr;
        } else
            cell.textLabel.text = staffStr;
    } else {
        const Person *const person = self.peopleList[indexPath.row];
        cell.textLabel.text = [person formattedName];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([indexPath isEqual:self.selectedContact]) {
        self.selectedContact = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        if (self.selectedContact) {
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.selectedContact];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }

        self.selectedContact = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    [self selectedPeople];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *str;
    
    if ((NSUInteger)section < self.teamList.count) {
        const Team *const team = self.teamList[section];
        str = team.name;
    } else
        str = NSLocalizedString(@"CHAT_PEOPLE_SECTION_HEADER", @"Section header for adding new chat representing players");
    
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    view.textLabel.attributedText  = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName : kTintColor}];
    view.contentView.backgroundColor = RGB_COLOR(222, 228, 235);
    
    return view;
}

#pragma mark - === Segue === -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"conversationTargetDone"]) {
        if (self.selectedContact)
            return YES;

        [BlockAlertView okWithMessage:NSLocalizedString(@"CHAT_MISSING_TARGET", @"Message to display when the press the done button on chat creation before selecting anyone")];
        return NO;
    }

    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (NSSet *)selectedPeople NS_RETURNS_RETAINED {
    if (!self.selectedContact)
        return nil;

    NSMutableSet *ary = [NSMutableSet new];

    const NSInteger section = self.selectedContact.section;
    const NSInteger row = self.selectedContact.row;

    if ((NSUInteger)section < self.teamList.count) {
        const Team *const team = self.teamList[section];
        const TeamPerson *const tp = self.teamPeople[team.sql_ident];

        if (row == 0) {
            // Everyone
            for (const TeamPerson *const teamPerson in team.people)
                [ary addObject:teamPerson.person];
        } else  {
            if (row == 1 && [tp hasCoachRole]) {
                // All coaches
                for (const TeamPerson *teamPerson in team.people)
                    if ([teamPerson hasCoachRole])
                        [ary addObject:teamPerson.person];
            } else {
                for (const TeamPerson *teamPerson in team.people)
                    if ([teamPerson isStaff])
                        [ary addObject:teamPerson.person];
            }
        }
    } else {
        [ary addObject:self.peopleList[row]];
    }

    return ary;
}

- (NSString *)conversationName {
    const NSInteger section = self.selectedContact.section;
    const NSInteger row = self.selectedContact.row;

    if ((NSUInteger)section < self.teamList.count) {
        const Team *const team = self.teamList[section];
        const TeamPerson *const tp = self.teamPeople[team.sql_ident];

        if (row == 0)
            return [NSString stringWithFormat:NSLocalizedString(@"CONVERSATION_TEAM_PLUS_ALL", @"Conversation title for all players on a team."), team.name];
        else  {
            if (row == 1 && [tp hasCoachRole])
                return [NSString stringWithFormat:NSLocalizedString(@"CONVERSATION_TEAM_ALL_COACHES", @"Conversation title for all coaches on a team."), team.name];
            else
                return [NSString stringWithFormat:NSLocalizedString(@"CONVERSATION_TEAM_ALL_STAFF", @"Conversation title for all staff on a team."), team.name];
        }
    } else
        return nil;
}

@end
