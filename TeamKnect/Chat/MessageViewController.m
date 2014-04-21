//
//  MessageViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/10/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageBubble.h"
#import "Conversation.h"
#import "Message.h"

#define kMessageOffset 10.    // The vertical spacing between message bubbles.
#define kPictureWidth 30.

typedef NS_ENUM(NSInteger, MessageBubbleSide) {
    Left, Right
};

@interface MessageViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
    CGFloat nextMessageY;
    CGFloat maxWidth;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *userInteractionView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userInteractionViewBottomConstraint;
@property (nonatomic, strong) UIView *scrollViewContent;
@end

@implementation MessageViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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

    maxWidth = CGRectGetWidth(self.scrollView.frame) * .6;

    self.scrollViewContent = [[UIView alloc] initWithFrame:self.scrollView.frame];

    nextMessageY = 10.;

    BOOL left = true;
    for (const Message *const message in self.conversation.messages) {
        [self addMessageBubbleToDisplay:message updateScrollView:NO side:left ? Left : Right];
        left = !left;
    }

    CGRect frame = self.scrollViewContent.frame;
    frame.size.height = nextMessageY;
    self.scrollViewContent.frame = frame;

    [self.scrollView addSubview:self.scrollViewContent];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame));
}

- (void)addMessageBubbleToDisplay:(const Message *const)message updateScrollView:(BOOL)update side:(MessageBubbleSide)side {
    MessageBubble *bubble;
    if (side == Left) {
        UIImageView *picture = nil;

        picture.frame = CGRectMake(5., nextMessageY, kPictureWidth, kPictureWidth);
        picture.layer.cornerRadius = kPictureWidth / 2.;   // 1/2 the width of the image
        picture.layer.borderWidth = 1.;
        picture.layer.borderColor = [UIColor whiteColor].CGColor;
        picture.clipsToBounds = YES;

        bubble = [[MessageBubble alloc] initLeftBubbleWithText:message.text maxWidth:maxWidth];
    } else
        bubble = [[MessageBubble alloc] initRightBubbleWithText:message.text maxWidth:maxWidth];

    CGRect frame = bubble.frame;
    frame.origin.y = nextMessageY;

    if (side == Right)
        frame.origin.x = CGRectGetWidth(self.scrollViewContent.frame) - CGRectGetWidth(frame) - 5.;
    else
        frame.origin.x = kPictureWidth + 10.;

    bubble.frame = frame;

    [self.scrollViewContent addSubview:bubble];

    nextMessageY += CGRectGetHeight(bubble.frame) + kMessageOffset;

    if (!update)
        return;

    frame = self.scrollViewContent.frame;
    frame.size.height = nextMessageY;
    self.scrollViewContent.frame = frame;

    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame));
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

#pragma mark - === Keyboard === -

- (void)keyboardWillShow:(NSNotification *)notification {
    const NSDictionary *const userInfo = [notification userInfo];

    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];

    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    self.userInteractionViewBottomConstraint.constant = CGRectGetHeight(keyboardRect);
    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    const NSDictionary *const userInfo = [notification userInfo];

    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    self.userInteractionViewBottomConstraint.constant = 0;
    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
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


- (IBAction)sendButtonPressed:(id)sender {
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0)
        return;

    self.textView.text = @"";

    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.conversation.managedObjectContext];
    message.text = text;
    message.conversation = self.conversation;

    [self.conversation.managedObjectContext save:NULL];

    [self addMessageBubbleToDisplay:message updateScrollView:YES side:Right];
}


@end