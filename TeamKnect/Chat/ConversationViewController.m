//
//  ConversationViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/9/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

// http://www.appcoda.com/how-to-add-search-bar-uitableview/

#import "ConversationViewController.h"
#import "ConversationTargetsViewController.h"
#import "NSManagedObjectContext+CoreDataImport.h"
#import "Conversation+FixNSSet.h"
#import "ChatViewController.h"
#import "ConversationCell.h"
#import "Person+Category.h"
#import "Conversation.h"
#import "WebServer.h"
#import "Message.h"
#import "Person.h"

@interface ConversationViewController () <UISearchDisplayDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSNumber *me;
@end

@implementation ConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.me = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];
      
    self.managedObjectContext = [[UIApplication sharedApplication].delegate performSelector:@selector(managedObjectContext)];

    self.searchDisplayController.displaysSearchBarInNavigationBar = NO;

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

    [self.tableView setEditing:editing animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    self.formatter = nil;
    self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    const NSInteger numRows = [self.tableView numberOfRowsInSection:0];
    if (numRows == 0)
        return;
    
    NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:numRows - 1 inSection:0];

    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self loadNewConversations:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerWithInterval:(NSTimeInterval)interval {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(loadNewConversations:) userInfo:nil repeats:NO];
    self.timer.tolerance = 1.;
}

- (void)loadNewConversations:(NSTimer *)timer {
    [timer invalidate];
    self.timer = nil;

    [Conversation loadConversationsWithParentContext:self.managedObjectContext
                                           onSuccess:^{
                                               // The load might complete after we've already left the screen.  No point in trying to update things and possibly crash.
                                               if ([self isViewLoaded])
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self.tableView reloadData];
                                                       [self timerWithInterval:5.];
                                                   });
                                           } onNoNewData:^{
                                               [self timerWithInterval:5.];
                                           } onFailure:^(NSError *error) {
                                               [self timerWithInterval:10.];
                                           }];
}

#pragma mark - === Table View === -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        const NSArray *const sections = [self.fetchedResultsController sections];
        if (sections.count > 0) {
            id<NSFetchedResultsSectionInfo> info = sections[0];
            return [info numberOfObjects];
        } else
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        const Conversation *const conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
        const Message *const message = [conversation.messages lastObject];

        ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversation" forIndexPath:indexPath];
        cell.date.text = [self.formatter stringFromDate:conversation.modified];
        cell.from.text = [conversation formattedNameExcluding:self.me];
        cell.text.text = message.text;

        return cell;
    }
}


- (NSDateFormatter *)formatter {
    if (_formatter == nil) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.doesRelativeDateFormatting = YES;
        _formatter.dateStyle = NSDateFormatterShortStyle;
        _formatter.timeStyle = NSDateFormatterNoStyle;
    }

    return _formatter;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil)
        return _fetchedResultsController;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Conversation"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modified" ascending:NO]];
    request.fetchBatchSize = 15;

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
    [self.tableView reloadData];
}

#pragma mark - === Segues === -

- (IBAction)chatWindowDoneButtonPressed:(UIStoryboardSegue *)sender {
    // Do nothing.  This is an Exit segue.
}

- (IBAction)didCancelConversationCreation:(UIStoryboardSegue *)sender {

}

- (IBAction)didChooseConversationTargets:(UIStoryboardSegue *)sender {
    ConversationTargetsViewController *vc = [sender sourceViewController];
    NSSet *people = [vc selectedPeople];

    [[WebServer sharedInstance] getNewConversationIdentWithName:[vc conversationName] people:people success:^(const NSArray *const data) {
        Conversation *conversation = [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:self.managedObjectContext];
        conversation.sql_ident = @([data[0] longValue]);

        conversation.people = people;
        conversation.name = [vc conversationName];

        [self performSegueWithIdentifier:@"conversationSelected" sender:conversation];
    } failure:^(NSError *error) {
        NSLog(@"%s: %@", __func__, error);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"conversationSelected"]) {
        ChatViewController *vc = [segue realDestinationViewController];

        if ([sender isKindOfClass:[Conversation class]]) {
            vc.conversation = sender;
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            vc.conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else if ([segue.identifier isEqualToString:@"newConversation"]) {
        ConversationTargetsViewController *vc = [segue realDestinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
    }

    if ([self.searchDisplayController isActive]) {

    } else {

    }
}

#pragma mark - === Search Bar === -

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.navigationItem.leftBarButtonItem = nil;
    controller.searchBar.showsCancelButton = YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    controller.searchBar.showsCancelButton = NO;
}

@end
