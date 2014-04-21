//
//  URLService.h
//  eNews
//
//  Created by Jangsan on 2/4/2014.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLService : NSObject
{

}

+ (URLService *) instance;
+ (void) deinit;

+ (NSString*) reqLoginUrl;
+ (NSString*) reqRegisterUrl;
+ (NSString*) reqGetPhotoUrl;
+ (NSString*) reqChangeNewEmailUrl;
+ (NSString*) reqChangeNewPasswordUrl;
+ (NSString*) reqSetPrivateInfoUrl;
+ (NSString*) reqSetImageDeleteUrl;
+ (NSString*) reqLogOutUrl;


+ (NSString*) reqResetPasswordUrl;
+ (NSString*) reqLocationsUrl;
+ (NSString*) reqSearchUrl;
+ (NSString*) reqCommentUrl;
+ (NSString*) reqUpdateUrl;
+ (NSString*) reqApproveUrl;
+ (NSString*) reqDeleteUrl;

+ (NSString*) iconURLWithName:(NSString*)name;

@end

URLService * Url();
