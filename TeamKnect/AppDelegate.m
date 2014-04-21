//
//  AppDelegate.m
//  TeamKnect
//
//  Created by Scott Grosch on 12/23/13.
//  Copyright (c) 2013 Gargoyle Software, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworkActivityIndicatorManager.h>
#import "NSManagedObjectContext+CoreDataImport.h"
#import "LeftUnderlayTableViewController.h"
#import "RegisterStepOneViewController.h"
#import "GSRevealViewController.h"
#import "Team+Category.h"
#import "TestFlight.h"
#import "TeamPerson.h"
#import "WebServer.h"
#import "Person.h"

#import "CalendarMap.h"
#import "CalendarMapExtras.h"

@interface AppDelegate () <NSURLSessionDelegate, UIAlertViewDelegate>
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) BOOL requestedAccessToCalendar;
@end

@implementation AppDelegate

- (void)registerDefaultsFromSettingsBundle
{
    const NSString *const settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    const NSDictionary *const settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];

    NSMutableDictionary *defaults = [NSMutableDictionary new];

    for (const NSDictionary *const pref in settings[@"PreferenceSpecifiers"]) {
        const NSString *const key = pref[@"Key"];
        if (!key)
            continue;

        defaults[key] = pref[@"DefaultValue"];
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


- (void)setupTheme {
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    THEMEEXT(UINavigationBar, setBarTintColor, 0, 162., 255.);

    CGFloat value = 88. / 255.;
    THEMEEXT(UITextField, setTextColor, value, value, value);

    THEME(UISegmentedControl, 0, 162., 255.);
    THEME(UITabBar, 0, 60., 110.);
    THEMEEXT(UITabBar, setSelectedImageTintColor, 0, 162., 255.);
    THEMEEXT(UITabBar, setBarTintColor, 222., 228., 235.);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"1b1390da-d643-47cb-b2ac-466597756f13"];
    [TestFlight setOptions:@{@"logToSTDERR" : @NO}];

    [self setupTheme];
    
    [self registerDefaultsFromSettingsBundle];

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard~iphone" bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"me"]) {
        UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier:@"registerNavigation"];
        self.window.rootViewController = nav;
        RegisterStepOneViewController *vc = (RegisterStepOneViewController *) [nav topViewController];
        vc.managedObjectContext = self.managedObjectContext;
        
        __typeof__(self) __weak weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:kMeSetNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            weakSelf.window.rootViewController = [[GSRevealViewController alloc] initWithFrontViewController:[storyboard instantiateViewControllerWithIdentifier:@"calendarDisplayNav"]
                                                                                          leftViewController:[storyboard instantiateViewControllerWithIdentifier:@"leftUnderlayViewController"]];
            [[NSNotificationCenter defaultCenter] removeObserver:weakSelf name:kMeSetNotification object:nil];
        }];
    } else
        self.window.rootViewController = [[GSRevealViewController alloc] initWithFrontViewController:[storyboard instantiateViewControllerWithIdentifier:@"calendarDisplayNav"]
                                                                              leftViewController:[storyboard instantiateViewControllerWithIdentifier:@"leftUnderlayViewController"]];
    
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (![[url scheme] isEqualToString:@"teamknect"])
        return NO;

    // http://blog.logichigh.com/2011/03/23/nsurl-cheat-sheet/

    NSString *query = [url host];
    if (!query)
        return NO;

    query = [query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSMutableDictionary *parameters = [NSMutableDictionary new];
    for (const NSString *const elem in [query componentsSeparatedByString:@"&"]) {
        const NSArray *const kvp = [elem componentsSeparatedByString:@"="];
        if (kvp.count != 2)
            continue;

        parameters[kvp[0]] = kvp[1];
    }

    parameters[@"personId"] = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];

    [[WebServer sharedInstance] registerForTeam:parameters success:^(const NSArray *const data) {
        // They're already a member of the team.
        if (data.count == 0)
            return;

        NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        importContext.parentContext = self.managedObjectContext;
        importContext.undoManager = nil;

        [importContext performBlockAndWait:^{
            const NSDictionary *const teamInfo = data[0];
            NSDictionary *teams = [importContext updateOrInsert:@[teamInfo] entityName:@"Team"];
            Team *team = teams[@([teamInfo[@"sql_ident"] longValue])];

            if (!team)
                return;

            [team createCalendar];

            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sport"];
            request.predicate = [NSPredicate predicateWithFormat:@"sql_ident = %@",  teamInfo[@"sport_id"]];
            NSArray *fetched = [importContext executeFetchRequest:request error:NULL];
            team.sport = [fetched firstObject];

            NSDictionary *people = [importContext updateOrInsert:data[1] entityName:@"Person"];
            NSDictionary *teamPeople = [importContext updateOrInsert:data[2] entityName:@"TeamPerson"];

            for (const NSDictionary *const teamPersonDetails in data[2]) {
                TeamPerson *tp = teamPeople[teamPersonDetails[@"sql_ident"]];
                tp.team = team;
                tp.person = people[teamPersonDetails[@"person_id"]];
            }

            NSError *error;
            if (![importContext save:&error]) {
                NSLog(@"%s: %@", __func__, error);
                return;
            }
        }];

        [self.managedObjectContext performBlock:^{
            [self.managedObjectContext save:NULL];
        }];
    } failure:^(NSError *error) {
        [BlockAlertView okWithTitle:WebServerDownTitle
                            message:NSLocalizedString(@"WEB_REGISTER_TEAM_FAIL", @"Message asking them to register for team later.")];
    }];

    return YES;
}

#pragma mark - === Require Calendar Access === -

- (void)displayCalendarWarning {
    [[[UIAlertView alloc] initWithTitle:nil
                                message:NSLocalizedString(@"MUST_ENABLE_CALENDAR", @"Message telling them they have to enable calendar access to use this app.")
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:nil]
     show];
}

- (void)loadCalendars {
    [[WebServer sharedInstance] getCalendarItemsWithSuccess:^(id data) {
        // Being an array means there were no entries.
        if ([data isKindOfClass:[NSArray class]])
            return;
        
        [[CalendarEventStore sharedInstance] importWebEvents:data managedObjectContext:self.managedObjectContext];
        [self.managedObjectContext save:NULL];
    } failure:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {
        [self loadCalendars];
        return;
    }
    
    // Calling requestAccessToEntityType:completion: doesn't make sense to do more than once as it'll always
    // return the value set in their preferences after the first time.  It won't re-prompt for access.
    if (self.requestedAccessToCalendar) {
        [self displayCalendarWarning];
        return;
    }

    self.requestedAccessToCalendar = YES;

    [[CalendarEventStore sharedInstance] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted)
            [self loadCalendars];
        else
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self displayCalendarWarning];
            });
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self applicationDidBecomeActive:nil];
}

#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TeamKnect" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TeamKnect"];

//    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.


         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}

         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
