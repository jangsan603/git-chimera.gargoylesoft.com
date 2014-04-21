//
//  CalendarMap+Category.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/6/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarMap.h"

@interface CalendarMap (Category)

/**
  * Marks the @c date as having been deleted from the sequence.
  * @param event The event occurrence which is being excluded.
  */
- (void)addExceptionDate:(const EKEvent *const)event;

@end
