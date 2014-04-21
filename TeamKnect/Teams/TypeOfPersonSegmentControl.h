//
//  TypeOfPersonSegmentControl.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/31/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// WARNING!  If you change this order, make sure awakeFromNib is still ordered correctly.
typedef NS_ENUM(NSInteger, TypeOfPersonSegments) {
    kPersonSegmentPerson,
    kPersonSegmentCoach,
    kPersonSegmentParent
};

@interface TypeOfPersonSegmentControl : UISegmentedControl

+ (NSInteger)numSegments;

@end
