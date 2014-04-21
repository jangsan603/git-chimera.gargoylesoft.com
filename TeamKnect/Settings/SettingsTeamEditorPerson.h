//
//  SettingsTeamEditorPerson.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/23/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsTeamEditorPerson : NSObject

@property (nonatomic, copy) NSString *first;
@property (nonatomic, copy) NSString *last;
@property (nonatomic, strong) NSNumber *sql;
@property (nonatomic, assign) BOOL joined;

- (instancetype)initWithPerson:(const Person *const)person;
- (instancetype)initWithDictionary:(const NSDictionary *const)dict;

@end
