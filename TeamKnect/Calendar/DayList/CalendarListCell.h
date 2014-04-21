//
//  CalendarListCell.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@interface CalendarListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *start;
@property (weak, nonatomic) IBOutlet UILabel *end;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIView *colorBar;

@end
