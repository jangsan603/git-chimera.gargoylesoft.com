//
//  SettingsProfile2ViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 4/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsProfile2ViewController.h"
#import "SettingsProfile3ViewController.h"

@interface SettingsProfile2ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dobLabel;
@property (weak, nonatomic) IBOutlet UITextField *dob;
@property (weak, nonatomic) IBOutlet UILabel *feetLabel;
@property (weak, nonatomic) IBOutlet UITextField *feet;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UITextField *weight;
@property (weak, nonatomic) IBOutlet UILabel *inchesLabel;
@property (weak, nonatomic) IBOutlet UITextField *inches;
@property (nonatomic, strong) AccessoryViewToolbar *toolbar;
@end

@implementation SettingsProfile2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *ary = [[NSMutableArray alloc] initWithArray:@[self.dob, self.weight, self.feet]];
    
    self.feetLabel.text = [LocalizedStrings feetLabel];
    self.weightLabel.text = [LocalizedStrings poundsLabel];
    
    if (IS_USING_METRIC) {
        self.feet.keyboardType = UIKeyboardTypeDecimalPad;
        self.weight.keyboardType = UIKeyboardTypeDecimalPad;
        
        self.feet.text = [self.person.height stringValue];
        self.weight.text = [self.person.weight stringValue];
        
        self.inchesLabel.hidden = YES;
        self.inches.hidden = YES;
    } else {
        [ary addObject:self.inches];

        self.feet.keyboardType = UIKeyboardTypeNumberPad;
        self.inches.keyboardType = UIKeyboardTypeNumberPad;
        self.weight.keyboardType = UIKeyboardTypeDecimalPad;
        
        self.inchesLabel.text = [LocalizedStrings inchesLabel];

        int feet;
        CGFloat inches;
        
        [Person convertToFeet:&feet inches:&inches fromMeters:[self.person.height floatValue]];

        self.feet.text = [NSString stringWithFormat:@"%d", feet];
        self.inches.text = [NSString stringWithFormat:@"%.1f", inches];
        self.inches.keyboardType = UIKeyboardTypeDecimalPad;
        
        self.weight.text = [NSString stringWithFormat:@"%.2f", [Person convertToImperialFromKilograms:[self.person.weight floatValue]]];
    }
    
    self.feet.placeholder = [LocalizedStrings feetPlaceholder];
    self.weight.placeholder = [LocalizedStrings poundsPlaceholder];
    self.inches.placeholder = NSLocalizedString(@"PROFILE_INCHES_PLACEHOLDER", @"Placeholder string for inches.");
    self.toolbar = [[AccessoryViewToolbar alloc] initAccessoryView:CGRectGetWidth(self.view.frame) textFields:ary inScrollView:nil];
    
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    picker.maximumDate = [NSDate date];
    picker.datePickerMode = UIDatePickerModeDate;
    picker.date = self.person.dob;
    
    [picker addTarget:self action:@selector(dateValueChanged:) forControlEvents:UIControlEventValueChanged];

    self.dob.inputView = picker;
    
    [self setupTextField:self.dob
                    text:[NSDateFormatter localizedStringFromDate:self.person.dob dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]
             placeholder:[LocalizedStrings birthdayPlaceholder]
              imageNamed:@"registerBirthday"];
    self.dobLabel.text = [LocalizedStrings birthdayLabel];
}

- (void)dateValueChanged:(UIDatePicker *)picker {
    self.dob.text = [NSDateFormatter localizedStringFromDate:picker.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    
    Person __weak *person = self.person;
    [self.editContext performBlock:^{
        person.dob = picker.date;
    }];
}

#pragma mark - === Segues === -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (![identifier isEqualToString:@"ps3"])
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    
    BOOL isUsingMetric = IS_USING_METRIC;
    
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    VALIDATE(feet, [LocalizedStrings feetMissing]);
    VALIDATE(weight, [LocalizedStrings poundsMissing]);
    
    int inchesValue = 0;
    if (!isUsingMetric) {
        VALIDATE(inches, [LocalizedStrings inchesMissing]);
        inchesValue = [inches intValue];
    }
    
    [self.editContext performBlockAndWait:^{
        if (isUsingMetric) {
            self.person.height = @([feet floatValue]);
            self.person.weight = @([weight floatValue]);
        } else {
            self.person.height = @([Person convertToMetricFromFeet:[feet intValue] inches:inchesValue]);
            self.person.weight = @([Person convertToMetricFromPounds:[weight floatValue]]);
        }
    }];
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ps3"]) {
        SettingsProfile3ViewController *vc = [segue realDestinationViewController];
        vc.editContext = self.editContext;
        vc.person = self.person;
    }
}

@end
