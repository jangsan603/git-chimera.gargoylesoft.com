//
//  AppleMapAnnotation.h
//  TeamKnect
//
//  Created by Scott Grosch on 2/3/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AppleMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
