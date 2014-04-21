//
//  URLService.m
//  eNews
//
//  Created by Jangsan on 2/4/2014.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "URLService.h"


@implementation URLService

static URLService *Instance = nil;

+ (URLService *) instance
{
	if (!Instance)
	{
		Instance = [URLService new];
	}
	
	return Instance;	
}

+ (void) deinit
{
	Instance = nil;
}

+ (NSString*) reqLoginUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://192.168.1.74/photo_backup/index.php/login"];
	return url;
}

+ (NSString*) reqRegisterUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://192.168.1.74/photo_backup/index.php/signup"];
	return url;
}

+ (NSString*) reqGetPhotoUrl
{
	NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://192.168.1.74/photo_backup/index.php/getfilelist"];
	return url;
}

+ (NSString*) reqChangeNewEmailUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://192.168.1.74/photo_backup/index.php/changeemail"];
	return url;
}

+ (NSString*) reqChangeNewPasswordUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://192.168.1.74/photo_backup/index.php/changepassword"];
	return url;
}

+ (NSString*) reqSetPrivateInfoUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://192.168.1.74/photo_backup/index.php/setprivatefile"];
	return url;

}

+ (NSString*) reqSetImageDeleteUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://192.168.1.74/photo_backup/index.php/deletefile"];
	return url;

}

+ (NSString*) reqLogOutUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://192.168.1.74/photo_backup/index.php/logout"];
	return url;
}




+ (NSString*) reqResetPasswordUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://movingport.com/api/resetpassword"];
	return url;
}

+ (NSString*) reqLocationsUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://movingport.com/api/getlocation"];
	return url;
}

+ (NSString*) reqSearchUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://movingport.com/api/getlocation"];
	return url;
}

+ (NSString*) reqCommentUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://movingport.com/api/savelocation"];
	return url;
}

+ (NSString*) reqUpdateUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://movingport.com/api/updatelocation"];
	return url;
}

+ (NSString*) reqApproveUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://movingport.com/api/approvelocation"];
	return url;
}

+ (NSString*) reqDeleteUrl
{
    NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://movingport.com/api/deletelocation"];
	return url;
}

+ (NSString*) iconURLWithName:(NSString*)name {
	return [NSString stringWithFormat:@"%@", name];
}

- (id) init
{
    if (self = [super init])
    {
	}
	return self;
}

@end

URLService * Url()
{
	return [URLService instance];
}
