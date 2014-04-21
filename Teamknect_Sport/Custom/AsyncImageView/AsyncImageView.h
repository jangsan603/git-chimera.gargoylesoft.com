//
//  AsyncImageView.h
//
//  Created by Jangsan on 3/30/04.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//


//
//

#import <UIKit/UIKit.h>

//@class AppManager;

@interface AsyncImageView : UIView {
    NSURLConnection *connection;
    NSMutableData *data;
    NSString *urlString; // key for image cache dictionary
	UIImage* image;
}

@property (nonatomic, retain) UIImage* image;
//@property(readwrite)int is_post;

-(void)loadImageFromURL:(NSURL*)url;

@end
