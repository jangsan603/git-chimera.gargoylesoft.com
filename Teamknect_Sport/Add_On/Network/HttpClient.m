//
//  HttpClient.m
//  eNews
//
//  Created by Jangsan on 2/4/2014.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "HttpClient.h"
#import "URLService.h"
#import "HttpClientPool.h"
#import "JSON.h"
#import <AssetsLibrary/AssetsLibrary.h>


@implementation HttpClient

@synthesize recievedData, statusCode, delegate, result, totalCount, identifier, requestType;

- (id)init 
{
	if (self = [super init])
    {
		[self reset];
	}
	return self;
}

- (void)reset
{
	self.recievedData = [NSMutableData data];
	connection = nil;
	statusCode = 0;	
	contentTypeIsXml = NO;
}

+ (NSString*)stringEncodedWithBase64:(NSString*)str
{
	static const char *tbl = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	const char *s = [str UTF8String];
	int length = [str length];
	char *tmp = malloc(length * 4 / 3 + 4);
	
	int i = 0;
	int n = 0;
	char *p = tmp;
	
	while (i < length)
    {
		n = s[i++];
		n *= 256;
		if (i < length) n += s[i];
		i++;
		n *= 256;
		if (i < length) n += s[i];
		i++;
		
		p[0] = tbl[((n & 0x00fc0000) >> 18)];
		p[1] = tbl[((n & 0x0003f000) >> 12)];
		p[2] = tbl[((n & 0x00000fc0) >>  6)];
		p[3] = tbl[((n & 0x0000003f) >>  0)];
		
		if (i > length) p[3] = '=';
		if (i > length + 1) p[2] = '=';
		
		p += 4;
	}
	
	*p = '\0';
	
	NSString *ret = [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
	free(tmp);
	
	return ret;
}

+ (NSString*) stringOfAuthorizationHeaderWithUsername:(NSString*)username password:(NSString*)password 
{
    return [@"Basic " stringByAppendingString:[HttpClient stringEncodedWithBase64:
											   [NSString stringWithFormat:@"%@:%@", username, password]]];
}

- (NSMutableURLRequest*)makeRequest:(NSString*)url 
{
	NSString            *encodedUrl = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																			  NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8));
	NSMutableURLRequest *request    = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:encodedUrl]];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setTimeoutInterval:TIMEOUT_SEC];
	[request setHTTPShouldHandleCookies:FALSE];
	[encodedUrl release];
	return request;
}

- (NSMutableURLRequest*)makeRequest:(NSString*)url username:(NSString*)username password:(NSString*)password 
{
	NSMutableURLRequest *request = [self makeRequest:url];
	[request setValue:[HttpClient stringOfAuthorizationHeaderWithUsername:username password:password]
   forHTTPHeaderField:@"Authorization"];
	return request;
}

- (void)prepareWithRequest:(NSMutableURLRequest*)request 
{
	// do nothing (for OAuthHttpClient)
}

- (void)requestGET:(NSString*)url
{
	[self reset];
	NSMutableURLRequest *request    = [self makeRequest:url];
	[self prepareWithRequest:request];
	connection                      = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)requestPOST:(NSString*)url body:(NSString*)body
{
	[self reset];
	NSMutableURLRequest *request = [self makeRequest:url];
    [request setHTTPMethod:@"POST"];
	if (body)
    {
		[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[self prepareWithRequest:request];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)requestGET:(NSString*)url username:(NSString*)username password:(NSString*)password
{
	[self reset];
	NSMutableURLRequest *request = [self makeRequest:url username:username password:password];
	connection                   = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)requestPOST:(NSString*)url body:(NSString*)body username:(NSString*)username password:(NSString*)password 
{
	[self reset];
	NSMutableURLRequest *request = [self makeRequest:url username:username password:password];
    [request setHTTPMethod:@"POST"];
	if (body)
    {
		[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	}
	connection                   = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)cancel 
{
	[connection cancel];
	[self reset];
	[self requestFailed:nil];
}

- (void)requestSucceeded
{
	self.result         = nil;
	self.totalCount     = 0;
	
	if (statusCode == 200)
    {
		switch (requestType)
        {
            case LOGIN_REQUEST:
            case UPLOAD_PHOTOIMAGE:
            case REGISTER_REQUEST:
            case PHOTO_GET_URL:
            case CHANGE_NEWEMAIL:
            case CHANGE_NEWPASSWORD:
            case SET_PRIVATEINFO:
            case SET_IMAGEDELETE:
            case LOGOUT:
            case CONFIRM_REQUEST:
            case CHANGE_REQUEST:
            case RESET_REQUEST:
			case LOCATION_REQUEST:
            case SEARCH_REQUEST:
            case COMMENT_REQUEST:
            case APPROVE_REQUEST:
            case EDIT_REQUEST:
            case DELETE_REQUEST:
            {
                NSString *respString = [[NSString alloc] initWithData:self.recievedData encoding:NSUTF8StringEncoding];
                
                NSLog(@"%@\n\n\n", respString);
                
                SBJSON *parser       = [[SBJSON alloc] init];
                result               = (NSDictionary *)[parser objectWithString:respString error:nil];            }
			break;
		}
		
		[delegate HttpClientSucceeded:self];
		[[HttpClientPool sharedInstance] releaseClient:self];
	}
	self.result                      = nil;
	self.totalCount                  = 0;
}

- (void)requestFailed:(NSError*)error 
{
	[delegate HttpClientFailed:self];
	[[HttpClientPool sharedInstance] releaseClient:self];
}

-(void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{ 
	[[challenge sender] cancelAuthenticationChallenge:challenge]; 
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse 
{
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	statusCode = [(NSHTTPURLResponse*)response statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.recievedData appendData:data];	
	NSString *parser = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"%@", parser);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self requestSucceeded];
	[self reset];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*) error
{
	[self requestFailed:error];
	[self reset];
}

//-----------jangsan login function.

- (void) reqLogin:(NSString*)userName Password:(NSString*)userPwd SecInfo:(NSString *)secInfo
{
    requestType = LOGIN_REQUEST;
	reqUrl      = [URLService reqLoginUrl];
	[self requestPOST:reqUrl body:[NSString stringWithFormat:@"email=%@&password=%@&secure_answer=%@", userName, userPwd, secInfo]];
}
//-------------jangsan signup funtion.
- (void) reqRegister:(NSString *)userEmail Password:(NSString *)userPassword SecurityInfo:(NSString *)securityInfo
{
    requestType = REGISTER_REQUEST;
	reqUrl      = [URLService reqRegisterUrl];
	[self requestPOST:reqUrl body:[NSString stringWithFormat:@"email=%@&password=%@&sec_answer=%@", userEmail, userPassword, securityInfo]];
}

//-------------jangsan photo uplaod function.

- (void) reqPhotoUpload:(NSString *)userId Token:(NSString *)authoToken File_Id:(NSString *)fileId FileExtention:(NSString *)fileExt PrivateInfo:(NSString *)privateInfo PhotoImage:(NSData *)photoImg
{
    requestType = UPLOAD_PHOTOIMAGE;
	reqUrl      = [URLService reqRegisterUrl];
    
}

//-------------jangsan photo url get function.

- (void) reqPhotoUrlGet:(NSString *)userId LoginToken:(NSString *)loginToken
{
    requestType = PHOTO_GET_URL;
 	reqUrl      = [URLService reqGetPhotoUrl];
    [self requestPOST:reqUrl body:[NSString stringWithFormat:@"self_id=%@&authtoken=%@",userId, loginToken]];
}

//-------------jangsan change new email function.

- (void) reqChangeUserEmail:(NSString *)userId Token:(NSString *)authoToken NewEmail:(NSString *)newEmail
{
    requestType = CHANGE_NEWEMAIL;
 	reqUrl      = [URLService reqChangeNewEmailUrl];
    [self requestPOST:reqUrl body:[NSString stringWithFormat:@"self_id=%@&authtoken=%@&email=%@",userId, authoToken, newEmail]];
}

//-------------jangsan change new password function.

- (void) reqChangeUserPassword:(NSString *)userId Token:(NSString *)authoToken NewPasword:(NSString *)newPwd
{
    requestType = CHANGE_NEWEMAIL;
 	reqUrl      = [URLService reqChangeNewPasswordUrl];
    [self requestPOST:reqUrl body:[NSString stringWithFormat:@"self_id=%@&authtoken=%@&password=%@",userId, authoToken, newPwd]];
}

//-------------jangsan set photo private information function.

- (void) reqSetPrivateInfo:(NSString *)userId Token:(NSString *)authoToken PostId:(int)postId PrivateInformation:(int)PrivateInfo
{
    requestType = SET_PRIVATEINFO;
 	reqUrl      = [URLService reqSetPrivateInfoUrl];
    [self requestPOST:reqUrl body:[NSString stringWithFormat:@"self_id=%@&authtoken=%@&post_id=%d&private=%d",userId, authoToken, postId,PrivateInfo]];
}

//------jangsan set image delete function.

- (void) reqSetImageDelete:(NSString *)userId Token:(NSString *)authoToken PostId:(int)postId
{
    requestType = SET_IMAGEDELETE;
 	reqUrl      = [URLService reqSetImageDeleteUrl];
    [self requestPOST:reqUrl body:[NSString stringWithFormat:@"self_id=%@&authtoken=%@&post_id=%d",userId, authoToken, postId]];
}
//------jangsan set logout function.

- (void) reqLogOut:(NSString *)userId Token:(NSString *)authoToken
{
    requestType = LOGOUT;
 	reqUrl      = [URLService reqLogOutUrl];
    [self requestPOST:reqUrl body:[NSString stringWithFormat:@"self_id=%@&authtoken=%@",userId, authoToken]];
}

@end
