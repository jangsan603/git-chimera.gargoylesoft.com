//
//  InjuryStatusHistoryViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/19/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "InjuryStatusHistoryViewController.h"
#import "InjuryStatusEditorViewController.h"
#import "InjuryQuickEditCell.h"
#import "Person+Category.h"
#import "InjuryStatus.h"
#import "Person.h"
#import "Injury.h"


@interface InjuryStatusHistoryViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) UINavigationItem *parentNavigationItem;
@property (nonatomic, assign) NSInteger injuryInfoSection;
@property (nonatomic, assign) NSInteger injuryHistorySection;
@property (nonatomic, assign) NSInteger injuryQuickEditSection;
@end

@implementation InjuryStatusHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
}

- (void)setPerson:(Person *)person {
    _person = person;
    
    if ([person.sql_ident isEqualToNumber:[[NSUserDefaults standardUserDefaults] valueForKey:@"me"]]) {
        self.injuryQuickEditSection = 0;
        self.injuryInfoSection = 1;
        self.injuryHistorySection = 2;
    } else {
        self.injuryQuickEditSection = -1;
        self.injuryInfoSection = 0;
        self.injuryHistorySection = 1;
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    self.formatter = nil;
    self.fetchedResultsController = nil;

    [super didReceiveMemoryWarning];
}

- (void)setNavBars:(UINavigationItem *)nav {
    if (nav)
        self.parentNavigationItem = nav;
    
    self.parentNavigationItem.leftItemsSupplementBackButton = YES;
    
    self.parentNavigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewInjury)];

    if ([self numberOfInjuries])
        self.parentNavigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editCurrentInjury)];
    else
        self.parentNavigationItem.leftBarButtonItem = nil;
}

#pragma mark - === Table View === -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.injuryHistorySection + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const Injury *injury;
    
    if (indexPath.section == self.injuryInfoSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
        
        injury = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

        cell.accessoryType = UITableViewCellAccessoryNone;

        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = [LocalizedStrings dateOfInjury];
                cell.detailTextLabel.text = [self.formatter stringFromDate:injury.doi];
                break;
            case 1:
                cell.textLabel.text = [LocalizedStrings dateOfReturn];
                cell.detailTextLabel.text = injury.dor ? [self.formatter stringFromDate:injury.dor] : @"";
                break;
            case 2:
                cell.textLabel.text = [LocalizedStrings injurySite];
                cell.detailTextLabel.text = injury.site;
                break;
            case 3:
                cell.textLabel.text = [LocalizedStrings injuryDetails];
                cell.detailTextLabel.text = @"";
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                break;
            case 4:
                cell.textLabel.text = [LocalizedStrings injuryAvailability];
                cell.detailTextLabel.text = [InjuryStatus textForStatus:injury.status];
                break;
            default:
                abort();
        }
        
        return cell;
    } else if (indexPath.section == self.injuryHistorySection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
        
        injury = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        cell.textLabel.text = injury.site;
        cell.detailTextLabel.text = [self.formatter stringFromDate:injury.doi];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        return cell;
    } else {
        InjuryQuickEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"quickEdit" forIndexPath:indexPath];
        
        __typeof__(self) __weak weakSelf = self;

        cell.onQuickEditSelected = ^(InjuryStatusType statusType) {
            __typeof__(self) __strong strongSelf = weakSelf;

            [[NSNotificationCenter defaultCenter] postNotificationName:kInjuryChangedNotification object:self userInfo:@{kInjuryChangedValue : @(statusType)}];
            
            if (statusType == InjuryStatusTypeAway || statusType == InjuryStatusTypeOK) {
                strongSelf.person.injury_status = @(statusType);
                [[WebServer sharedInstance] updateInjuryStatusForPerson:strongSelf.person success:nil failure:nil];
            } else {
                [self performSegueWithIdentifier:@"editInjury" sender:@(statusType)];
            }
        };
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Injury *injury = nil;

    if (indexPath.section == self.injuryInfoSection) {
        if (indexPath.row == 3)
            injury = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    } else if (indexPath.section == self.injuryHistorySection)
        injury = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];

    if (injury)
        [self performSegueWithIdentifier:@"editInjury" sender:injury];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == self.injuryQuickEditSection)
        return 1;

    const NSInteger num = [self numberOfInjuries];
    if (num == 0)
        return 0;

    if (section == self.injuryInfoSection)
        return 5;

    return num;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *str;
    
    if (section == self.injuryInfoSection)
        str = NSLocalizedString(@"INJURY_INFO_SECTION_HEADER", @"Title for the current injury's information");
    else if (section == self.injuryHistorySection)
        str = NSLocalizedString(@"INJURY_HISTORY_SECTION_HEADER", @"Title for all of the person's historical injuries.");
    else
        str = @"";
    
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    view.textLabel.attributedText  = [[NSAttributedString alloc] initWithString:[str uppercaseStringWithLocale:[NSLocale currentLocale]] attributes:@{NSForegroundColorAttributeName : kTintColor}];
    view.contentView.backgroundColor = RGB_COLOR(222, 228, 235);
    
    return view;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger section = indexPath.section;
    
    if (section == self.injuryHistorySection) {
        return indexPath;
    } else if (section == self.injuryInfoSection) {
        return indexPath.row == 3 ? indexPath : nil;
    } else {
        return nil;
    }
}


- (NSDateFormatter *)formatter {
    if (_formatter)
        return _formatter;

    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateStyle = NSDateFormatterShortStyle;
    _formatter.timeStyle = NSDateFormatterNoStyle;

    return _formatter;
}

#pragma mark - === Fetched Results Controller

- (NSInteger)numberOfInjuries {
    const NSArray *const sections = [self.fetchedResultsController sections];
    if (sections.count > 0) {
        id<NSFetchedResultsSectionInfo> info = sections[0];
        return [info numberOfObjects];
    } else
        return 0;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil)
        return _fetchedResultsController;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Injury"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"doi" ascending:NO]];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                    managedObjectContext:self.person.managedObjectContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];

    _fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error])
        NSLog(@"%s: %@", __func__, error);

    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
    [self setNavBars:nil];
}

#pragma mark - === Segue === -

- (void)addNewInjury {
    [self performSegueWithIdentifier:@"editInjury" sender:nil];
}

- (void)editCurrentInjury {
    [self performSegueWithIdentifier:@"editInjury" sender:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editInjury"]) {
        InjuryStatusEditorViewController *vc = [segue realDestinationViewController];
        vc.person = self.person;
        vc.statusType = InjuryStatusTypeOut;
        
        if ([sender isKindOfClass:[Injury class]])
            vc.injury = sender;
        else if ([sender isKindOfClass:[NSNumber class]])
            vc.statusType = [sender integerValue];
    }
}

- (IBAction)injuryEditingDone:(UIStoryboardSegue *)sender {

}


@end
  