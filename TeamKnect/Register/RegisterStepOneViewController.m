//
//  RegisterLoginViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/5/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "RegisterStepOneViewController.h"
#import "NSManagedObjectContext+CoreDataImport.h"
#import "RegisterStepTwoViewController.h"
#import <HTEmailAutocompleteTextField.h>
#import "AccessoryViewToolbar.h"
#import "Person+Category.h"
#import "Team+Category.h"
#import "CalendarMap.h"
#import "AppDelegate.h"
#import "TeamPerson.h"
#import "WebServer.h"
#import "Sport.h"

@interface RegisterStepOneViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet HTEmailAutocompleteTextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *instructions;
@property (nonatomic, strong) AccessoryViewToolbar *toolbar;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation RegisterStepOneViewController

NSString *const kLoadFullNotification = @"loadFullNotification";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"REGISTER_SIGN_UP", @"Navigation bar header for the sign up screen when initially registering.");

    self.instructions.text = NSLocalizedString(@"REGISTER_INSTRUCTIONS", @"Text telling them to register with name/pwd and we'll either create new account or link to existing.");

    self.email.placeholder = [LocalizedStrings emailPlaceholder];
    self.password.placeholder = [LocalizedStrings passwordPlaceholder];
    [self.doneButton setTitle:NSLocalizedString(@"REGISTER_CONTINUE_BUTTON", @"The continue button to press on the first registration screen")
                     forState:UIControlStateNormal];

    self.toolbar = [[AccessoryViewToolbar alloc] initAccessoryView:CGRectGetWidth(self.view.frame)
                                                        textFields:@[self.email, self.password]
                                                      inScrollView:nil];

    self.email.inputAccessoryView = self.toolbar;
    self.password.inputAccessoryView = self.toolbar;

    CGFloat value = 235. / 255.;
    self.view.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1];

    self.doneButton.backgroundColor = [UIColor colorWithRed:9./255. green:116./255. blue:194./255. alpha:1];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.email.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registerEmail"]];
    self.email.leftViewMode = UITextFieldViewModeAlways;

    self.password.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registerLock"]];
    self.password.leftViewMode = UITextFieldViewModeAlways;

#if DEBUG
    self.email.text = @"Scott.Grosch@icloud.com";
#else
    self.email.text = @"degroote@mac.com";
#endif
    self.password.text = @"qqqqqq";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.email becomeFirstResponder];
    
    // If we came back from register screen two, we don't want this spinning
    [self.activityIndicator stopAnimating];
}

#define VALIDATE(var, str) NSString *var = [self.var.text stringByTrimmingCharactersInSet:ws]; if (var.length == 0) { [BlockAlertView okWithMessage:str]; return; }

- (IBAction)doneButtonPressed:(id)sender {
    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];

    VALIDATE(email, [LocalizedStrings emailMissing]);
    VALIDATE(password, [LocalizedStrings passwordMissing]);

    if (password.length < 6) {
        [BlockAlertView okWithMessage:[LocalizedStrings passwordTooShort]];
        return;
    }

    NSDictionary *params = @{@"email" : email, @"password" : password};

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];

    [[WebServer sharedInstance] registerStepOne:params
                                        success:^(NSArray *data) {
                                            if (data.count == 0)
                                                return;
                                            
                                            if (data[0] == [NSNull null]) {
                                                // Account exists, wrong password
                                                [BlockAlertView okWithMessage:NSLocalizedString(@"WRONG_REGISTER_PASSWORD_MESSAGE", @"Message stating that the account they specified exists, but the password is wrong.")];

                                                [self.activityIndicator stopAnimating];
                                                [self.activityIndicator removeFromSuperview];
                                                self.activityIndicator = nil;
                                                return;
                                            }

                                            NSInteger ident = [data[0] longValue];
                                            if (ident > 0) {
                                                // Existing account
                                                [[NSUserDefaults standardUserDefaults] setValue:@(ident) forKey:@"me"];
                                                
                                                [[WebServer sharedInstance] getFullDetailsWithSuccess:^(const NSDictionary *const data) {
                                                    [self populateCoreDataForExistingAccount:data];

                                                    // Notification sent here so that it's *after* the person is really created
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kMeSetNotification object:@(ident)];

                                                    [self.activityIndicator stopAnimating];
                                                    [self.activityIndicator removeFromSuperview];
                                                    self.activityIndicator = nil;

                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                } failure:^(NSError *error) {
                                                    [BlockAlertView okWithMessage:NSLocalizedString(@"MY_DOWNLOAD_FAILED", @"Message stating we were not able to download their information.")];
                                                    NSLog(@"%s: %@", __func__, error);
                                                    [self.activityIndicator stopAnimating];
                                                    [self.activityIndicator removeFromSuperview];
                                                    self.activityIndicator = nil;
                                                }];

                                                return;
                                            }

                                            // It's a new account, so move on.
                                            [self performSegueWithIdentifier:@"registerStepTwo" sender:params];
                                        } failure:^(NSError *error) {
                                            [self.activityIndicator stopAnimating];
                                            [self.activityIndicator removeFromSuperview];
                                            self.activityIndicator = nil;

                                            if ([[error userInfo][AFNetworkingOperationFailingURLResponseErrorKey] statusCode] == 400)
                                                [BlockAlertView okWithMessage:NSLocalizedString(@"NOT_AN_EMAIL", @"Message stating that what they entered doesn't look like an email address.")];
                                            else
                                                [BlockAlertView okWithMessage:NSLocalizedString(@"COMMUNICATION_FAILED", @"Message saying something failed, please try later.")];
                                        }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"registerStepTwo"]) {
        RegisterStepTwoViewController *vc = [segue destinationViewController];
        vc.params = sender;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.email)
        [self.password becomeFirstResponder];
    else {
        [self.password resignFirstResponder];
        [self.doneButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }

    return YES;
}

// This will only get called if it's a new device that links to an existing account
- (void)populateCoreDataForExistingAccount:(const NSDictionary *const)data {
    NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    importContext.parentContext = self.managedObjectContext;
    importContext.undoManager = nil;

    [importContext performBlockAndWait:^{
        NSDictionary *people = [importContext updateOrInsert:data[@"people"] entityName:@"Person"];
        NSDictionary *teams = [importContext updateOrInsert:data[@"teams"] entityName:@"Team"];
        NSDictionary *sports = [importContext updateOrInsert:data[@"sports"] entityName:@"Sport"];

        for (const NSDictionary *const dict in data[@"teams"]) {
            Team *team = teams[dict[@"sql_ident"]];
            team.sport = sports[dict[@"sport_id"]];
        }

        // TODO: These could all come back as blank arrays if it's a real person who belongs to nothing yet.
        // e.g. Installed app and registered, but hasn't joined any teams yet.
        id details = data[@"details"];
        if ([details isKindOfClass:[NSDictionary class]])
            [(NSDictionary *)details enumerateKeysAndObjectsUsingBlock:^(const NSString *const key, const NSArray *const obj, BOOL *stop) {
                Team *team = teams[@((long)[key longLongValue])];
                
                [team createCalendar];
                
                NSDictionary *teamPeople = [importContext updateOrInsert:obj entityName:@"TeamPerson"];
                for (const NSDictionary *const dict in obj) {
                    long teamPersonId = (long) [dict[@"sql_ident"] longValue];
                    
                    TeamPerson *teamPerson = teamPeople[@(teamPersonId)];
                    teamPerson.team = team;
                    teamPerson.person = people[@([dict[@"person_id"] longValue])];
                }
                
            }];
        
        // If it's not a dictionary, it was an empty array.
        if ([data[@"events"] isKindOfClass:[NSDictionary class]]) {
            [[CalendarEventStore sharedInstance] importWebEvents:data[@"events"] managedObjectContext:importContext];
        }

        NSString *picture = data[@"picture"];
        if (picture.length) {
            Person *const me = people[[[NSUserDefaults standardUserDefaults] valueForKey:@"me"]];
            NSData *const imageData = [[NSData alloc] initWithBase64EncodedString:picture options:0];
            
            [me assignImage:[UIImage imageWithData:imageData]];
        }
        
        NSError *error = nil;
        if (![importContext save:&error]) {
            NSLog(@"%s: %@", __func__, error);
        }
    }];
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError *e2;
        if (![self.managedObjectContext save:&e2])
            NSLog(@"2) %s: %@", __func__, e2);
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFullNotification object:nil];
}

@end
