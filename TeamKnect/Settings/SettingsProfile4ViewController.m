//
//  SettingsProfile4ViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 4/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsProfile4ViewController.h"
#import "AccessoryViewToolbar.h"

@interface SettingsProfile4ViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *country;
@property (weak, nonatomic) IBOutlet UITextField *nationality;
@property (nonatomic, strong) AccessoryViewToolbar *toolbar;
@property (nonatomic, copy) NSArray *countries;
@end

@implementation SettingsProfile4ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"countries" withExtension:@"plist"];
    self.countries = [NSArray arrayWithContentsOfURL:url];
    
    UIPickerView *picker = [UIPickerView new];
    picker.delegate = self;
    picker.dataSource = self;
    
    self.country.text = self.person.country_of_birth;
    self.country.inputView = picker;
    self.country.placeholder = NSLocalizedString(@"COUNTRY_PLACEHOLDER", @"Placeholder text for country of birth");
    
    self.nationality.text = self.person.nationality;
    self.nationality.autocorrectionType = UITextAutocorrectionTypeYes;
    self.nationality.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.nationality.placeholder = NSLocalizedString(@"NATIONALITY_PLACEHOLDER", @"Placeholder text for nationality.");
    
    self.toolbar = [[AccessoryViewToolbar alloc] initAccessoryView:CGRectGetWidth(self.view.frame) textFields:@[self.country, self.nationality] inScrollView:nil];
}

#pragma mark - === Picker === -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.country.text = self.countries[row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.countries count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.countries[row];
}

#pragma mark - === Segues === -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (![identifier isEqualToString:@"settingsProfileDone"])
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    VALIDATE(country, NSLocalizedString(@"PROFILE_COUNTRY_MISSING", @"Message stating country is missing."));
    VALIDATE(nationality, NSLocalizedString(@"PROFILE_NATIONALITY_MISSING", @"Message stating nationality is missing."));
    
    [self.editContext performBlockAndWait:^{
        self.person.nationality = nationality;
        self.person.country_of_birth = country;
        
        NSError *error;
        if (![self.editContext save:&error]) {
            NSLog(@"%s: CHILD: %@", __func__, error);
            
            [self.editContext.parentContext performBlockAndWait:^{
                NSError *e2;
                if (![self.editContext.parentContext save:&e2])
                    NSLog(@"%s: PARENT: %@", __func__, e2);
            }];
        }
    }];
    
    return YES;
}

@end
