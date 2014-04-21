//
//  AddTeamMemberChooseRoleViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/13/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "AddTeamMemberChooseRoleViewController.h"
#import "AddTeamMembersEmailViewController.h"
#import "TeamPerson+Category.h"

@interface AddTeamMemberChooseRoleViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *instructions;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *inviteButton;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, assign) NSNumber *role;
@end

@implementation AddTeamMemberChooseRoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.presentingViewController isKindOfClass:[UINavigationController class]])
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissMe)];
    
    self.peopleByRole = [NSMutableDictionary new];
    
    self.tableData = @[
                       @[@"Athletic Trainer", @(kAthleticTrainerRole)],
                       @[@"Coach", @(kCoachRole)],
                       @[@"Family", @(kFamilyRole)],
                       @[@"Fan", @(kFanRole)],
                       @[@"Friend", @(kFriendRole)],
                       @[@"Player", @(kPlayerRole)],
                       @[@"Parent", @(kParentRole)],
                       @[@"Scout", @(kScoutRole)],
                       @[@"Sponsor", @(kSponsorRole)],
                       @[@"Staff", @(kStaffRole)],
                       @[@"Team Doctor", @(kTeamDoctorRole)],
                       @[@"Team Manager", @(kTeamManagerRole)]
                       ];

    self.inviteButton.title = NSLocalizedString(@"ADD_PLAYERS_INVITE_BUTTON", @"The title for the invite button");
    self.instructions.text = @"Instruction for douche bags here that can't figure this out.";
    self.instructions.numberOfLines = 0;
}

#pragma mark - === Table View === -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
    cell.textLabel.text = self.tableData[indexPath.row][0];
    
    NSArray *people = self.peopleByRole[self.tableData[indexPath.row][1]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld people", (long)people.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.role = self.tableData[indexPath.row][1];
    [self performSegueWithIdentifier:@"choosePeople" sender:indexPath];
}

#pragma mark - === Segues === -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"choosePeople"]) {
        AddTeamMembersEmailViewController *vc = [segue realDestinationViewController];
        vc.initialEmails = self.peopleByRole[self.role];
        
        const NSIndexPath *const ip = sender;
        vc.roleName = self.tableData[ip.row][0];
    }
}

- (IBAction)returnToTeamMembersRoleChooser:(UIStoryboardSegue *)sender {
    AddTeamMembersEmailViewController *vc = [sender sourceViewController];
    if (vc.emails.count == 0)
        return;
    
    self.peopleByRole[self.role] = [[NSArray alloc] initWithArray:vc.emails];
    
    [self.tableView reloadData];
}

- (void)dismissMe {
    [self performSegueWithIdentifier:@"cancelTeamEditor" sender:self];
}

@end
