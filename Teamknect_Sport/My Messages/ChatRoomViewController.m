//
//  ChatRoomViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/3/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import "ChatRoomViewController.h"

@interface ChatRoomViewController ()<JSMessagesViewDelegate, JSMessagesViewDataSource, UINavigationBarDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSMutableArray            *messageArray;
@property (strong, nonatomic) NSMutableArray            *timestamps;
@property (strong, nonatomic) UIImage                   *willSendImage;

@end

@implementation ChatRoomViewController
@synthesize messageArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.delegate               = self;
    self.dataSource             = self;
    self.messageArray           = [NSMutableArray array];
    self.timestamps             = [NSMutableArray array];
}

#pragma  mark - TableView data source.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

#pragma  mark - Message view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    [self.messageArray addObject:[NSDictionary dictionaryWithObject:text forKey:@"Text"]];
    [self.timestamps addObject:[NSDate date]];
    
    if ((self.messageArray.count - 1)%2)
        [JSMessageSoundEffect playMessageSentSound];
    else
        [JSMessageSoundEffect playMessageReceivedSound];
    [self finishSend];
}

- (void)cameraPressed:(id)sender
{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? JSBubbleMessageTypeIncoming :JSBubbleMessageTypeOutgoing;
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"])
    {
        return  JSBubbleMediaTypeText;
    }
    else if ([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"])
    {
        return JSBubbleMediaTypeImage;
    }
    return -1;
}

- (UIButton *)sendButton
{
    return  [UIButton defaultSendButton];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
    return JSAvatarStyleCircle;
}

- (JSInputBarStyle)inputBarStyle
{
    return  JSInputBarStyleFlat;
}

#pragma mark - Messages View data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.messageArray objectAtIndex:indexPath.row]objectForKey:@"Text"])
    {
        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"];
    }
    return nil;
}

- (NSDate *) timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImage *)avatarImageForIncomingMessage
{
    return  [UIImage imageNamed:@"3.jpg"];
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return  [UIImage imageNamed:@"4.jpg"];
}

- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"])
    {
        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"];
    }
    return nil;
}

- (IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"Chose image!  Details:  %@", info);

    self.willSendImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.messageArray addObject:[NSDictionary dictionaryWithObject:self.willSendImage forKey:@"Image"]];
    [self.timestamps addObject:[NSDate date]];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
