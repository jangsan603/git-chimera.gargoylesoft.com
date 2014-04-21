//
//  MyLocationViewController.m
//  TeamkNect
//
//  Created by Jangsan on 4/16/14.
//  Copyright (c) 2014 lion. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "Person.h"
#import "SVAnnotation.h"
#import "SVPulsingAnnotationView.h"
#import "MyLocationViewController.h"

@interface MyLocationViewController ()<MKMapViewDelegate>

@end

@implementation MyLocationViewController
@synthesize viewLocation;
@synthesize txtZipCode;

#pragma mark - current location view.

@synthesize  viewCurrentLocation;
@synthesize  lblCurrentLocation;
@synthesize  currentPositionMapView;
@synthesize  txtSelectZipCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - view up-down effect.
- (void)viewWillAppear:(BOOL)animated
{
    deviceOrientation = UIInterfaceOrientationPortrait;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.3f];
    self.viewLocation.frame = CGRectMake(self.viewLocation.frame.origin.x, self.viewLocation.frame.origin.y, self.viewLocation.frame.size.width, self.viewLocation.frame.size.height);
    if (deviceOrientation == UIInterfaceOrientationPortrait)
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     -70,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
    }
    else if (deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     70,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
    }
    
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.3f];
    
    if (UIInterfaceOrientationIsPortrait(deviceOrientation))
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     0,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
    }
    
    [UIView commitAnimations];
    
}

- (IBAction)btnSaveClicked:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    self.viewCurrentLocation.frame = CGRectMake(320,
                                                61,
                                                320,
                                                self.viewCurrentLocation.frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)btnCancelClicked:(id)sender
{
     [self.revealViewController revealToggleAnimated:YES];
}

- (IBAction)btnLocationClicked:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    self.viewCurrentLocation.frame = CGRectMake(0,
                                                61,
                                                320,
                                                self.viewCurrentLocation.frame.size.height);
    [currentPositionMapView.layer setBorderColor:[UIColor colorWithRed:0 green:0.635 blue:1 alpha:1.0].CGColor];
    [currentPositionMapView.layer setBorderWidth:2.0];
    [currentPositionMapView.layer setCornerRadius:5.0];
    [self userCurrentLocation];
    [UIView commitAnimations];
}

#pragma mark - user current location.
- (void)userCurrentLocation
{
    AppDelegate *appDelegate    = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext        = appDelegate.managedObjectContext;
    NSFetchRequest *request     = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    Person *person;
    
    if ([mutableFetchResults count] == 1) {
        person = [mutableFetchResults objectAtIndex:0];
        
    }
    else if([mutableFetchResults count] == 0)
    {
        NSLog(@"Error- No User \n");
        //  assert(![mutableFetchResults count]);
    }
    else{
        NSLog(@"Error- Multi User \n");
    }
    
    double   user_latitude   = [person.latitude doubleValue];
    double   user_longitude  = [person.longitude doubleValue];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(user_latitude, user_longitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.1, 0.1));
    [self.currentPositionMapView setRegion:region animated:NO];
    
    SVAnnotation *annotation = [[SVAnnotation alloc] initWithCoordinate:coordinate];
    annotation.title = @"Current Location";
    annotation.subtitle = person.address;
    [self.currentPositionMapView addAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[SVAnnotation class]]) {
        static NSString *identifier = @"currentLocation";
		SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.currentPositionMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if(pulsingView == nil) {
			pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationColor = [UIColor colorWithRed:0.678431 green:0 blue:0 alpha:1];
            pulsingView.canShowCallout = YES;
        }
		
		return pulsingView;
    }
    
    return nil;
}

#pragma mark - TextFieldDelegate.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtZipCode resignFirstResponder];
    [txtSelectZipCode resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
