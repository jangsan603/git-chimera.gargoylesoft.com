//
//  TeamListViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 12/25/13.
//  Copyright (c) 2013 Gargoyle Software, LLC. All rights reserved.
//

#import "TeamListViewController.h"
#import "NSManagedObjectContext+CoreDataImport.h"
#import "PersonBigPictureViewController.h"
#import "PersonDetailsViewController.h"
#import "TypeOfPersonSegmentControl.h"
#import "GSRevealViewController.h"
#import "Person+Category.h"
#import "TeamPerson.h"
#import "JerseyCell.h"
#import "WebServer.h"
#import "Picture.h"
#import "Person.h"
#import "Team.h"

@interface TeamListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, copy) NSArray *peopleOnTab;
@property (nonatomic, strong) NSMutableDictionary *sectionContentViewControllers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *controlRowIndexPath;
@end

@implementation TeamListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.team.name;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MenuBar"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonPressed)];

    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;

    [self buildAccordianSections];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[WebServer sharedInstance] getListOfPlayersForTeam:self.team
                                                success:^(NSArray *data) {
                                                    if (data.count != 2)
                                                        return;

                                                    NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                                                    importContext.parentContext = self.managedObjectContext;
                                                    importContext.undoManager = nil;

                                                    [importContext performBlock:^{
                                                        [importContext updateOrInsert:data[0] entityName:@"Person"];
                                                        const NSDictionary *const importedTeamPerson = [importContext updateOrInsert:data[1] entityName:@"TeamPerson"];
                                                        
                                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sql_ident == $IDENT"];
                                                        
                                                        for (const NSDictionary *const teamPerson in data[1]) {
                                                            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
                                                            request.predicate = [predicate predicateWithSubstitutionVariables:@{@"IDENT" : teamPerson[@"person_id"]}];
                                                            
                                                            NSError *error = nil;
                                                            NSArray *ary = [importContext executeFetchRequest:request error:&error];
                                                            if (ary.count == 0 || error != nil) {
                                                                NSLog(@"Um, this shouldn't happen!  %s: %@", __func__, error);
                                                                continue;
                                                            }
                                                            
                                                            Person *person = [ary firstObject];
                                                            
                                                            TeamPerson *tp = importedTeamPerson[@([teamPerson[@"sql_ident"] longValue])];
                                                            tp.person = person;
                                                            tp.team = (Team *) [importContext objectWithID:self.team.objectID];
                                                        };
                                                        
                                                        [importContext save:NULL];
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self buildAccordianSections];
                                                            [self.tableView reloadData];
                                                        });
                                                    }];
                                                } failure:^(NSError *error) {
                                                    NSLog(@"Failed to download: %@", error);
                                                }];
}

#pragma mark - === Table View === -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JerseyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
    cell.teamPerson = self.peopleOnTab[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"personSelected" sender:self.peopleOnTab[indexPath.row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.peopleOnTab count];
}

- (void)buildAccordianSections {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TeamPerson"];
    request.predicate = [NSPredicate predicateWithFormat:@"team == %@", self.team];
    request.propertiesToFetch = @[@"jersey"];
    [request setRelationshipKeyPathsForPrefetching:@[@"person.last", @"person.first", @"person.injury_status"]];

    NSArray *unsorted = [self.managedObjectContext executeFetchRequest:request error:nil];

    NSArray *descriptors = @[
                             [NSSortDescriptor sortDescriptorWithKey:@"person.injury_status" ascending:YES],
                             [NSSortDescriptor sortDescriptorWithKey:@"person.last" ascending:YES],
                             [NSSortDescriptor sortDescriptorWithKey:@"person.first" ascending:YES]
                             ];
    self.peopleOnTab = [unsorted sortedArrayUsingDescriptors:descriptors];
}


- (IBAction)segmentValueChanged:(TypeOfPersonSegmentControl *)sender {
}

#pragma mark - === Segues === -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"personSelected"]) {
        PersonBigPictureViewController *vc = [segue destinationViewController];
        vc.teamPerson = sender;
    }
}

- (void)menuButtonPressed {
    [[NSNotificationCenter defaultCenter] postNotificationName:GSRevealViewControllerToggleLeftViewController object:self];
}

@end
