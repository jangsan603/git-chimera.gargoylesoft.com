//
//  MyLocationViewController.h
//  TeamkNect
//
//  Created by lion on 4/16/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SWRevealViewController.h"

@interface MyLocationViewController : UIViewController<UITextFieldDelegate>
{
     NSManagedObjectContext *managedObjectContext;
     UIInterfaceOrientation deviceOrientation;
}

@property (strong, nonatomic) IBOutlet UIView                *viewLocation;
@property (strong, nonatomic) IBOutlet UIButton              *btnSave;
@property (strong, nonatomic) IBOutlet UIButton              *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton              *btnLocation;
@property (strong, nonatomic) IBOutlet UITextField           *txtZipCode;

- (IBAction)btnSaveClicked:(id)sender;
- (IBAction)btnCancelClicked:(id)sender;
- (IBAction)btnLocationClicked:(id)sender;

#pragma mark - current location view variable.
@property (strong, nonatomic) IBOutlet UIView                *viewCurrentLocation;
@property (strong, nonatomic) IBOutlet UILabel               *lblCurrentLocation;
@property (strong, nonatomic) IBOutlet UITextField           *txtSelectZipCode;
@property (strong, nonatomic) IBOutlet MKMapView             *currentPositionMapView;
@end
