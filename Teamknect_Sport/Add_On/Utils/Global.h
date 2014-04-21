//
//  Global.h
//  Backup Vault
//
//  Created by Jangsan on 3/19/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <Foundation/Foundation.h>

extern      int                       globalSelectImgViewIndex;      //------image view select index (ex:football, tennis ...etc).
extern      int                       globalSelectDetailImgIndex;    //------detail image view select index (ex:cute t-shirt...etc).
extern      int                       globalSelectDetailImgIndex_1;  //------detail imgae view select index (ex:cute t-shirt...etc).
//extern    NSMutableArray            *globalImgPostIdArr;           //------uploaded image post id.
//extern    NSMutableArray            *globalImgFileIdArr;           //------uploaded image file id.
//extern    NSMutableArray            *globalImgDataArr;             //------uploaded image data (url array).
//extern    NSMutableArray            *globalImgPrivateInfoArr;      //------uploaded image private information (array).
//extern    int                       global_signup_login_flag;      //------signup or login user flag.


#define OBJECT_SINGLETON_BOILERPLATE(_object_name_, _shared_obj_name_) \
static _object_name_ *z##_shared_obj_name_ = nil;  \
+ (_object_name_ *)_shared_obj_name_ {             \
@synchronized(self) {                            \
if (z##_shared_obj_name_ == nil) {             \
/* Note that 'self' may not be the same as _object_name_ */                               \
/* first assignment done in allocWithZone but we must reassign in case init fails */      \
z##_shared_obj_name_ = [[self alloc] init];                                               \
}                                              \
}                                                \
return z##_shared_obj_name_;                     \
}                                                  \
+ (id)allocWithZone:(NSZone *)zone {               \
@synchronized(self) {                            \
if (z##_shared_obj_name_ == nil) {             \
z##_shared_obj_name_ = [super allocWithZone:zone]; \
return z##_shared_obj_name_;                 \
}                                              \
}                                                \
\
/* We can't return the shared instance, because it's been init'd */ \
return nil;                                    \
}                                                  \
//- (id)retain {                                     \
//return self;                                   \
//}                                                  \
//- (NSUInteger)retainCount {                        \
//return NSUIntegerMax;                          \
//}                                                  \
//- (void)release {                                  \
//}                                                  \
//- (id)autorelease {                                \
//return self;                                   \
//}                                                  \
//- (id)copyWithZone:(NSZone *)zone {                \
//return self;                                   \
//}

@interface Global : NSObject

@end
