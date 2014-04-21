//
//  SendMessageViewController.h
//  TeamkNect
//
//  Created by Jangsan on 4/3/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendMessageViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton            *btnBack;            //--------back button event.
@property (strong, nonatomic) IBOutlet UIButton            *btnSend;            //--------send button event.
@property (strong, nonatomic) IBOutlet UILabel             *lblName;            //--------name text.
@property (strong, nonatomic) IBOutlet UITextView          *txtViewMsgContent;  //--------message content variable;

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnSendClicked:(id)sender;

@end
