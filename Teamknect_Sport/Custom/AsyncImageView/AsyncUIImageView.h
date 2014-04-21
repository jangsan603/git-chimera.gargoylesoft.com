//
//  AsyncImageView.h
//
//  Created by Jangsan on 3/30/04.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncUIImageView : UIImageView
{
    NSURLConnection *connection;
    NSMutableData   *data;
    NSString        *urlString; // key for image cache dictionary
}

- (void)setImageURL:(NSURL *)url placeholder:(UIImage *)image;
- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)style;

@end
