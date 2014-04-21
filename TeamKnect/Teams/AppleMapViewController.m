//
//  AppleMapViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/3/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "AppleMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AppleMapAnnotation.h"
#import "Person+Category.h"

@interface AppleMapViewController () 
@property (weak, nonatomic) IBOutlet MKMapView *map;
@end

@implementation AppleMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.person.latitude && self.person.longitude)
        [self displayMap];
}

- (void)displayMap {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.person.latitude doubleValue],
                                                              [self.person.longitude doubleValue]);

    AppleMapAnnotation *annotation = [AppleMapAnnotation new];
    annotation.title = [self.person formattedName];
    annotation.subtitle = self.person.address;
    annotation.coordinate = coord;

    [self.map addAnnotation:annotation];

    self.map.selectedAnnotations = @[annotation];

    self.map.region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(.1, .1));
}


@end
