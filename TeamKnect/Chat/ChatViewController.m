//
//  ChatViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/29/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "ChatViewController.h"
#import "NSManagedObjectContext+CoreDataImport.h"
#import "UITextView+VisibleBorder.h"
#import "RightMessageBubbleCell.h"
#import "LeftMessageBubbleCell.h"
#import "Conversation+FixNSSet.h"
#import "SpringyFlowLayout.h"
#import "Person+Category.h"
#import "Conversation.h"
#import "WebServer.h"
#import "Message.h"


@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutGuide;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSNumber *me;
@property (nonatomic, assign) CGFloat maxBubbleWidth;
@property (nonatomic, assign) CGFloat screenWidth;
@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.textView showBorder];

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.me = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];

    self.maxBubbleWidth = CGRectGetWidth(self.view.frame) * .6;

    self.screenWidth = CGRectGetWidth([[UIScreen mainScreen] applicationFrame]);

    self.textView.textContainerInset = UIEdgeInsetsZero;

    self.cameraButton.enabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];

    [self.sendButton setTitle:NSLocalizedString(@"MESSAGE_SEND_BUTTON", @"The button to press to send the chat message.") forState:UIControlStateNormal];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self loadNewMessages:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerWithInterval:(NSTimeInterval)interval {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(loadNewMessages:) userInfo:nil repeats:NO];
    self.timer.tolerance = 1.;
}

- (void)loadNewMessages:(NSTimer *)timer {
    [timer invalidate];
    self.timer = nil;

    [Conversation loadConversationsWithParentContext:self.conversation.managedObjectContext
                                           onSuccess:^{
                                               // The load might complete after we've already left the screen.  No point in trying to update things and possibly crash.
                                               [self timerWithInterval:5.];
                                           } onNoNewData:^{
                                               [self timerWithInterval:5.];
                                           } onFailure:^(NSError *error) {
                                               [self timerWithInterval:10.];
                                           }];
}

#pragma mark - === Table View === -

- (void)configureCell:(BaseMessageBubbleCell *)cell atIndexPath:(NSIndexPath *const)indexPath {
    const Message *const message = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell setText:message.text maxBubbleWidth:self.maxBubbleWidth];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    const NSArray *const sections = [self.fetchedResultsController sections];
    if (sections.count > 0) {
        id<NSFetchedResultsSectionInfo> info = sections[0];
        return [info numberOfObjects];
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const Message *const message = [self.fetchedResultsController objectAtIndexPath:indexPath];

    const BOOL bubbleGoesOnRight = [message.sender.sql_ident isEqualToNumber:self.me];

    BaseMessageBubbleCell *cell = [tableView dequeueReusableCellWithIdentifier:bubbleGoesOnRight ? @"right" : @"left" forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static LeftMessageBubbleCell *left = nil;
    static RightMessageBubbleCell *right = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        left = [tableView dequeueReusableCellWithIdentifier:@"left"];
        right = [tableView dequeueReusableCellWithIdentifier:@"right"];
    });

    const Message *const message = [self.fetchedResultsController objectAtIndexPath:indexPath];

    BaseMessageBubbleCell *const cell = [message.sender.sql_ident isEqualToNumber:self.me] ? right : left;

    [self configureCell:cell atIndexPath:indexPath];
    [cell layoutIfNeeded];

    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.;
}

#pragma mark - === Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil)
        return _fetchedResultsController;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"conversation = %@", self.conversation];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                    managedObjectContext:self.conversation.managedObjectContext
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
#pragma mark - === Keyboard === -

- (void)keyboardWillShow:(NSNotification *)notification {
    const NSDictionary *const userInfo = [notification userInfo];

    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];

    self.bottomLayoutGuide.constant = CGRectGetHeight(keyboardRect);
    [self.view setNeedsUpdateConstraints];

    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    const NSDictionary *const userInfo = [notification userInfo];

    self.bottomLayoutGuide.constant = 0;
    [self.view setNeedsUpdateConstraints];

    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)sendButtonPressed:(id)sender {
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0)
        return;

    self.textView.text = @"";

    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.conversation.managedObjectContext];
    message.text = text;
    message.conversation = self.conversation;
    message.created = [NSDate date];

    [self.conversation.managedObjectContext save:NULL];

    [[WebServer sharedInstance] sendChatText:text
                                    toPeople:self.conversation.people
                             forConversation:self.conversation
                                     success:^(const NSArray *const data) {
                                         message.sql_ident = @([data[0] longValue]);
                                     }
                                     failure:^(NSError *error) {
                                         NSLog(@"Failed to send chat: %@", error);
                                     }];
}

#pragma mark - === Camera === -

- (IBAction)cameraButtonPressed:(UIButton *)sender {
    BOOL camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL library = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];

    if (library && camera) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:kCancelButton
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"TAKE_PHOTO", @"Action button to take photo"),
                                NSLocalizedString(@"CHOOSE_PHOTO", @"Action button to choose existing photo"), nil];
        [sheet showInView:self.view];
    } else if (camera)
        [self showUIImagePickerControllerWithButtonIndex:0];
    else
        [self showUIImagePickerControllerWithButtonIndex:1];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex)
        return;

    [self showUIImagePickerControllerWithButtonIndex:buttonIndex];
}

- (void)showUIImagePickerControllerWithButtonIndex:(NSInteger)buttonIndex {
    UIImagePickerController *camera = [UIImagePickerController new];

    if (buttonIndex == 0) {
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;

        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
            camera.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else
        camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    camera.delegate = self;
    camera.allowsEditing = YES;
    camera.view.tintColor = self.view.tintColor;

    [self presentViewController:camera animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = (UIImage *) info[UIImagePickerControllerEditedImage];
    if (image == nil)
        image = (UIImage *) info[UIImagePickerControllerOriginalImage];

    // Shrink it down to a 100x100 image
    const CGSize size = CGSizeMake(100., 100.);

    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    {
        CGRect rect = CGRectZero;
        rect.size = size;

        [image drawInRect:rect];
        //        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
