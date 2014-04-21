//
//  PersonDetailsInfoViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/21/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "PersonDetailsInfoViewController.h"
#import "Person+Category.h"
#import "TeamPerson.h"

@implementation PersonDetailsInfoViewController

- (void)setNavBars:(UINavigationItem *)nav {
    nav.leftBarButtonItem = nil;
    nav.rightBarButtonItem = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"POSITION_LABEL", @"Label for player position on details page.");
            cell.detailTextLabel.text = self.teamPerson.position;
            break;
        case 1:
            cell.textLabel.text =  NSLocalizedString(@"HEIGHT_LABEL", @"Label for person's height on details page.");
            cell.detailTextLabel.text = [self.teamPerson.person formattedWeight];
            break;
        case 2:
            cell.textLabel.text =  NSLocalizedString(@"WEIGHT_LABEL", @"Label for person's weight on details page.");
            cell.detailTextLabel.text = [self.teamPerson.person formattedHeight];
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"DOB_HEADER", @"The date of birth string from the player details table.");
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.teamPerson.person.dob dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
            break;
        case 4:
            cell.textLabel.text = NSLocalizedString(@"SHOT_HEADER", @"The shot header from the player details table");
            cell.detailTextLabel.text = self.teamPerson.shot;
            break;
        case 5:
            cell.textLabel.text = NSLocalizedString(@"COUNTRY_HEADER", @"The country the person comes from for the player details table.");
            cell.detailTextLabel.text = self.teamPerson.person.country_of_birth;
            break;
        case 6:
            cell.textLabel.text = NSLocalizedString(@"NATIONALITY_HEADER", @"The nationality of the person for the player details table.");
            cell.detailTextLabel.text = self.teamPerson.person.nationality;
            break;
        default:
            cell.textLabel.text = @"Foo";
            cell.detailTextLabel.text = @"Bar";
            break;

    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

@end
