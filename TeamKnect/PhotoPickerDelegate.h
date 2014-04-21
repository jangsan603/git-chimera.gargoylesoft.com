//
//  PhotoPickerDelegate.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

typedef void (^PhotoPickerImagePicked)(UIImage *image);

@interface PhotoPickerDelegate : NSObject <UIImagePickerControllerDelegate>

- (instancetype)initWithView:(UIView *)view fromViewController:(UIViewController *)viewController onImagePicked:(PhotoPickerImagePicked)onImagePicked;
- (void)pickImage:(UIView *)sender;

@end
