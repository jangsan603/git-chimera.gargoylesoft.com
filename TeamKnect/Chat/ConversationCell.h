//
//  ConversationCell.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/9/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *from;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
