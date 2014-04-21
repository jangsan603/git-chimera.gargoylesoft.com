//
//  HttpClientPool.h
//  eNews
//
//  Created by Jangsan on 2/4/2014.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum HttpClientPoolClientType
{
	GeneralClient,
	ImageClient,
	
} HttpClientPoolClientType;

@interface HttpClientPool : NSObject
{
	NSMutableArray *clientsActive;
	NSMutableArray *clientsIdle;
}

+ (HttpClientPool*)sharedInstance;

- (id)idleClientWithType:(HttpClientPoolClientType)type;
- (void)releaseClient:(id)client;
- (void)removeAllIdleObjects;
- (int)activeClientCountWithType:(HttpClientPoolClientType)type;
- (void)addIdleClientObserver:(id)observer selector:(SEL)selector;
- (void)removeIdleClientObserver:(id)observer;

@end
