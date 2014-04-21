//
//  Picture.h
//  TeamKnect
//
//  Created by Scott Grosch on 4/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Picture : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) Person *person;

@end
