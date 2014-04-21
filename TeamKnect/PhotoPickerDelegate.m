//
//  PhotoPickerDelegate.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "PhotoPickerDelegate.h"

@interface PhotoPickerDelegate () <UIActionSheetDelegate, UINavigationControllerDelegate>
@property (nonatomic, copy) PhotoPickerImagePicked onImagePicked;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIView *view;
@end

@implementation PhotoPickerDelegate

- (instancetype)initWithView:(UIView *)view fromViewController:(UIViewController *)viewController onImagePicked:(PhotoPickerImagePicked)onImagePicked {
    if ((self = [super init])) {
        self.onImagePicked = onImagePicked;
        self.view = view;
        self.viewController = viewController;
    }
    
    return self;
}

- (void)pickImage:(UIView *)sender {
    BOOL camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL library = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (library && camera) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:kCancelButton
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"TAKE_PHOTO", @"Action button to take photo"),
                                NSLocalizedString(@"CHOOSE_PHOTO", @"Action button to choose existing photo"), nil];
        [sheet showFromRect:sender.frame inView:self.view animated:YES];
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
    camera.allowsEditing = NO;
    camera.view.tintColor = self.view.tintColor;
    
    [self.viewController presentViewController:camera animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = (UIImage *) info[UIImagePickerControllerEditedImage];
    if (image == nil)
        image = (UIImage *) info[UIImagePickerControllerOriginalImage];

    [self.viewController dismissViewControllerAnimated:YES completion:nil];

    self.onImagePicked(image);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    self.onImagePicked(nil);
}

@end
