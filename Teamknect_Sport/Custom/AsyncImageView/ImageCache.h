//
//  ImageCache.h
//  YellowJacket
//
//  Created by Jangsan Squires on 5/4/2014.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageCacheObject;

@interface ImageCache : NSObject
{
    NSUInteger              totalSize;              //----------total number of bytes.
    NSUInteger              maxSize;                //----------maximum capacity.
    NSMutableDictionary     *myDictionary;          //----------dictionary variable.
}

@property (nonatomic, readonly) NSUInteger totalSize;

-(id)initWithMaxSize:(NSUInteger) max;
-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key;
-(UIImage*)imageForKey:(NSString*)key;

@end
