//
//  HttpClient.h
//  eNews
//
//  Created by Jangsan on 2/4/2014.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TIMEOUT_SEC		20.0

typedef enum _tagHTTPClientRequestType
{
    LOGIN_REQUEST,
    REGISTER_REQUEST,
    UPLOAD_PHOTOIMAGE,
    PHOTO_GET_URL,
    CHANGE_NEWEMAIL,
    CHANGE_NEWPASSWORD,
    SET_PRIVATEINFO,
    SET_IMAGEDELETE,
    LOGOUT,
    CONFIRM_REQUEST,
    CHANGE_REQUEST,
    RESET_REQUEST,
    LOCATION_REQUEST,
    SEARCH_REQUEST,
    COMMENT_REQUEST,
    APPROVE_REQUEST,
    EDIT_REQUEST,
    DELETE_REQUEST
} HTTPClientRequestType;

@class HttpClient;
@protocol DDHttpClientDelegate
- (void)HttpClientSucceeded:(HttpClient*)sender;
- (void)HttpClientFailed:(HttpClient*)sender;
@end

@interface HttpClient : NSObject
{
	NSURLConnection		*connection;
	NSMutableData		*recievedData;
	int					statusCode;
	BOOL				contentTypeIsXml;
	
	NSDictionary        *result;
	int					totalCount;
	
	NSString			*identifier;
	HTTPClientRequestType		requestType;
	id<DDHttpClientDelegate>	delegate;
	
	NSString*			reqUrl;
    
    //--------------Photo uploading request in background.
    
}

@property (retain) NSMutableData                *recievedData;
@property (readonly) int                        statusCode;
@property (assign) id<DDHttpClientDelegate> delegate;
@property (retain) 	NSDictionary                *result;
@property (retain) 	NSString                    *resultString;
@property (assign) 	int                         totalCount;
@property (copy) 	NSString                    *identifier;
@property (assign) HTTPClientRequestType		requestType;

- (void)requestGET:(NSString*)url;
- (void)requestPOST:(NSString*)url body:(NSString*)body;
- (void)requestGET:(NSString*)url username:(NSString*)username password:(NSString*)password;
- (void)requestPOST:(NSString*)url body:(NSString*)body username:(NSString*)username password:(NSString*)password;

- (void)cancel;
- (void)requestSucceeded;
- (void)requestFailed:(NSError*)error;
- (void)reset;

//-------jangsan login API function.

- (void) reqLogin:(NSString*)userName Password:(NSString*)userPwd SecInfo:(NSString *)secInfo;

//-------jangsan signup API function.

- (void) reqRegister:(NSString *)userEmail Password:(NSString *)userPassword SecurityInfo:(NSString *)securityInfo;

//-------jangsan photo upload API function.

- (void) reqPhotoUpload:(NSString *)userId Token:(NSString *)authoToken File_Id:(NSString *)fileId FileExtention:(NSString *)fileExt PrivateInfo:(NSString *)privateInfo PhotoImage:(NSData *)photoImg;

//------jangsan photo url get function.

- (void) reqPhotoUrlGet:(NSString *)userId LoginToken:(NSString *)loginToken;

//------jangsan change useremail function.

- (void) reqChangeUserEmail:(NSString *)userId Token:(NSString *)authoToken NewEmail:(NSString *)newEmail;

//------jangsan change userpassword function.

- (void) reqChangeUserPassword:(NSString *)userId Token:(NSString *)authoToken NewPasword:(NSString *)newPwd;

//------jangsan set private information function.

- (void) reqSetPrivateInfo:(NSString *)userId Token:(NSString *)authoToken PostId:(int)postId PrivateInformation:(int)PrivateInfo;

//------jangsan set image delete function.

- (void) reqSetImageDelete:(NSString *)userId Token:(NSString *)authoToken PostId:(int)postId;

//------jangsan set logout function.

- (void) reqLogOut:(NSString *)userId Token:(NSString *)authoToken;


@end
