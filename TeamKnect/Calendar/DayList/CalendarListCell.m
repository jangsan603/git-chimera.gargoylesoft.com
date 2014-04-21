//
//  CalendarListCell.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarListCell.h"

@implementation CalendarListCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.start.textColor = RGB_COLOR(0, 60., 110.);
    self.end.textColor = RGB_COLOR(29., 31., 33.);
    self.title.textColor = RGB_COLOR(102., 107., 112.);
}

@end
