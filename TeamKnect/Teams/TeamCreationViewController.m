//
//  TeamCreationViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/23/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "TeamCreationViewController.h"
#import "AddTeamMemberChooseRoleViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AccessoryViewToolbar.h"
#import <EventKit/EventKit.h>
#import "Team+Category.h"
#import "WebServer.h"
#import "Sport.h"
#import "Team.h"

@interface TeamCreationViewController () <CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *teamName;
@property (weak, nonatomic) IBOutlet UITextField *sport;
@property (weak, nonatomic) IBOutlet UITextField *zipCode;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) AccessoryViewToolbar *toolbar;
@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, strong) NSNumber *selectedSport;
@end

@implementation TeamCreationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nextButton.title = NSLocalizedString(@"NEXT_BAR_BUTTON_ITEM", @"Button in nav bar to move to the next screen");
    self.sport.placeholder = NSLocalizedString(@"NEW_SPORT_NAME", @"Placeholder text for the sport");
    self.teamName.placeholder = NSLocalizedString(@"NEW_TEAM_NAME", @"Placeholder text for creating a new team name");
    self.zipCode.placeholder = NSLocalizedString(@"NEW_TEAM_ZIP", @"Zip code for new team");
    self.zipCode.keyboardType = UIKeyboardTypeNumberPad;

    self.toolbar = [[AccessoryViewToolbar alloc] initAccessoryView:CGRectGetWidth(self.view.frame)
                                                        textFields:@[self.teamName, self.self.zipCode, self.sport]
                    inScrollView:nil];


    UIPickerView *picker = [UIPickerView new];
    picker.delegate = self;
    picker.dataSource = self;

    self.sport.inputView = picker;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sport"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.pickerData = [self.managedObjectContext executeFetchRequest:request error:NULL];

    const Sport *const sport = [self.pickerData firstObject];
    self.selectedSport = sport.sql_ident;
    self.sport.text = sport.name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    const CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        [BlockAlertView okWithMessage:NSLocalizedString(@"GRANT_LOCALIZATION", @"Message asking them to grant location services.")];
        return;
    }

    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;

    [self.manager startMonitoringSignificantLocationChanges];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.teamName becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.manager stopMonitoringSignificantLocationChanges];
    self.manager.delegate = nil;
    self.manager = nil;

    [self.geocoder cancelGeocode];
    self.geocoder = nil;
}

#pragma mark - === Location Management === -

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // Stop right away if we got something.  This frees up the manager memory now, vs. waiting
    // for the view to go away.
    [manager stopMonitoringSignificantLocationChanges];
    self.manager.delegate = nil;
    self.manager = nil;

    // Most recent location update is at the end of the array
    CLLocation *location = [locations lastObject];

    __typeof__(self) __weak weakSelf = self;

    self.geocoder = [[CLGeocoder alloc] init];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        const CLPlacemark *const placemark = [placemarks firstObject];
        if (placemark == nil)
            return;

        __typeof__(self) __strong strongSelf = weakSelf;
        strongSelf.zipCode.text = placemark.postalCode;
//        strongSelf.city.text = placemark.locality;
//        strongSelf.state.text = placemark.administrativeArea;
//        strongSelf.country.text = placemark.country;

//        NSString *url = [NSString stringWithFormat:@"http://api.geonames.org/postalCodeSearchJSON?postalcode=%@&country=%@&username=gargoylesoft",
//                         placemark.postalCode, placemark.ISOcountryCode];
    }];
    
}

#pragma mark - === Sport Picker === -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    const Sport *const sport = self.pickerData[row];
    self.selectedSport = sport.sql_ident;
    self.sport.text = sport.name;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerData count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    const Sport *const sport = self.pickerData[row];
    return sport.name;
}

#pragma mark - === Segues === -

#define VALIDATE(var, str) NSString *var = [self.var.text stringByTrimmingCharactersInSet:ws]; if (var.length == 0) { [BlockAlertView okWithMessage:str]; return NO; }

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"create"]) {
        NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];

        VALIDATE(teamName, NSLocalizedString(@"CREATE_TEAM_NAME_MISSING", @"Message to display when they didn't enter a team name on team creation."));
        VALIDATE(zipCode, NSLocalizedString(@"CREATE_TEAM_ZIP_MISSING", @"Message to display when they didn't enter a zip code on team creation"));
        VALIDATE(sport, NSLocalizedString(@"CREATE_TEAM_SPORT_MISSING", @"Message to display when they didn't enter a team name."));

        return YES;
    }

    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"create"]) {
        NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        childContext.parentContext = self.managedObjectContext;
        childContext.undoManager = nil;

        Team *team = [NSEntityDescription insertNewObjectForEntityForName:@"Team" inManagedObjectContext:childContext];
        team.name = self.teamName.text;
        team.zip = self.zipCode.text;

        // We stored the selected sport's sql_ident instead of a Sport object directly because this is a different
        // context now and you can't cross contexts.
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sport"];
        request.predicate = [NSPredicate predicateWithFormat:@"sql_ident == %@", self.selectedSport];

        const NSArray *const objs = [childContext executeFetchRequest:request error:NULL];
        team.sport = [objs firstObject];

        AddTeamMemberChooseRoleViewController *vc = [segue realDestinationViewController];
        vc.team = team;
        vc.managedObjectContext = childContext;
    }
}

 @end
