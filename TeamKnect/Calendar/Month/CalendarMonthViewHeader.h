//
//  CalendarMonthViewHeader.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/8/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

typedef void (^CalendarMonthViewBlock)(BOOL previous);

@interface CalendarMonthViewHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *date;
@property (nonatomic, copy) CalendarMonthViewBlock onMonthChangePressed;

@end
