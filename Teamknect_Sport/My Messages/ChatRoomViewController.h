//
//  ChatRoomViewController.h
//  TeamkNect
//
//  Created by Jangsan on 4/3/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"

@interface ChatRoomViewController :JSMessagesViewController<UIImagePickerControllerDelegate>
{
    
}

@property (strong, nonatomic) IBOutlet UIButton             *btnBack;           //------back button event.
@property (strong, nonatomic) IBOutlet UIButton             *btnSend;           //------send button event.
@property (strong, nonatomic) IBOutlet UITextField          *txtMsgContent;     //------message textfield.


- (IBAction)btnBackClicked:(id)sender;

@end
