//
//  InjuryStatus.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/19/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

// The order of these values can NEVER change or the database will be all kinds of !@#$%^ up.
typedef NS_ENUM(NSInteger, InjuryStatusType) {
    InjuryStatusTypeOut,
    InjuryStatusTypePractice,
    InjuryStatusTypeAway,
    InjuryStatusTypeOK
};

@interface InjuryStatus : NSObject

+ (NSString *)textForStatus:(const NSNumber *const)status;
+ (UIImage *)imageForStatus:(const NSNumber *const)status;
+ (UIImage *)circledImageForStatus:(const NSNumber *const)status selected:(BOOL)selected;

@end
