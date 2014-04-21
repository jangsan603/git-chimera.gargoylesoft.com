//
//  InjuryStatusEditorViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/4/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "InjuryStatusEditorViewController.h"
#import "UITextView+VisibleBorder.h"
#import "AccessoryViewToolbar.h"
#import "InjuryStatus.h"
#import "Person.h"
#import "Injury.h"

@interface InjuryStatusEditorViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraint;
@property (weak, nonatomic) IBOutlet UITextField *injuryDate;
@property (weak, nonatomic) IBOutlet UITextField *recoveryDate;
@property (weak, nonatomic) IBOutlet UITextField *site;
@property (weak, nonatomic) IBOutlet UITextField *availability;
@property (weak, nonatomic) IBOutlet UITextView *details;
@property (weak, nonatomic) IBOutlet UILabel *injuryDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *recoveryDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *availabilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *siteLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIPickerView *availabilityPicker, *sitePicker;
@property (nonatomic, copy) NSArray *siteLabels;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) AccessoryViewToolbar *toolbar;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSManagedObjectContext *childContext;
@end

@implementation InjuryStatusEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.details showBorder];
    
    UIColor *const color = kTintColor;
    
    self.injuryDateLabel.textColor = color;
    self.recoveryDateLabel.textColor = color;
    self.siteLabel.textColor = color;
    self.detailsLabel.textColor = color;
    self.availabilityLabel.textColor = color;
    
    self.injuryDateLabel.text = [LocalizedStrings dateOfInjury];
    self.recoveryDateLabel.text = [LocalizedStrings dateOfReturn];
    
    self.siteLabel.text = [LocalizedStrings injurySite];
    self.site.autocorrectionType = UITextAutocorrectionTypeYes;
    
    self.detailsLabel.text = [LocalizedStrings injuryDetails];
    self.details.text = @"";
    self.details.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.details.autocorrectionType = UITextAutocorrectionTypeYes;
    
    self.availabilityLabel.text = [LocalizedStrings injuryAvailability];
    
    self.toolbar = [[AccessoryViewToolbar alloc] initAccessoryView:CGRectGetWidth(self.view.frame)
                                                        textFields:@[self.injuryDate, self.recoveryDate, self.site, self.availability, self.details]
                                                      inScrollView:self.scrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    [self.datePicker addTarget:self action:@selector(dateValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.injuryDate.inputView = self.datePicker;
    self.recoveryDate.inputView = self.datePicker;
    
    self.availabilityPicker = [[UIPickerView alloc] init];
    self.availabilityPicker.delegate = self;
    self.availabilityPicker.dataSource = self;
    self.availability.inputView = self.availabilityPicker;
    
    self.sitePicker = [[UIPickerView alloc] init];
    self.sitePicker.delegate = self;
    self.sitePicker.dataSource = self;
    self.site.inputView = self.sitePicker;
    
    self.siteLabels = @[
                        NSLocalizedString(@"INJURY_SITE_UPPER_BODY", @"The injury site was the upper body"),
                        NSLocalizedString(@"INJURY_SITE_LOWER_BODY", @"The injury site was the lower body"),
                        NSLocalizedString(@"INJURY_SITE_CONCUSSION", @"The injury site was a concussion"),
                        NSLocalizedString(@"INJURY_SITE_OTHER", @"The injury site was elsewhere")
                        ];
    
    self.childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.childContext.parentContext = self.person.managedObjectContext;
    self.childContext.undoManager = nil;
    
    if (self.injury) {
        self.injuryDate.text = [self.formatter stringFromDate:self.injury.doi];
        self.recoveryDate.text = [self.formatter stringFromDate:self.injury.dor];
        self.site.text = self.injury.site;
        self.availability.text = [InjuryStatus textForStatus:self.injury.status];
        self.details.text = self.injury.details;
        
        self.injury = (Injury *) [self.childContext objectWithID:self.injury.objectID];
    } else {
        self.injury = [NSEntityDescription insertNewObjectForEntityForName:@"Injury" inManagedObjectContext:self.childContext];
        self.injury.doi = [NSDate date];
        self.injury.person = (Person *) [self.childContext objectWithID:self.person.objectID];
        self.injury.site = self.siteLabels[0];
        self.injury.status = @(self.statusType);
        self.site.text = self.injury.site;
        self.injuryDate.text = [self.formatter stringFromDate:[NSDate date]];
        self.availability.text = [InjuryStatus textForStatus:@(self.statusType)];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    self.formatter = nil;
    [super didReceiveMemoryWarning];
}

- (NSDateFormatter *)formatter {
    if (_formatter)
        return _formatter;
    
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateStyle = NSDateFormatterShortStyle;
    _formatter.timeStyle = NSDateFormatterNoStyle;
    
    return _formatter;
}

#pragma mark - === Date Picker === -

- (void)dateValueChanged:(UIDatePicker *)picker {
    if ([self.injuryDate isFirstResponder]) {
        self.injuryDate.text = [self.formatter stringFromDate:picker.date];
        self.injury.doi = picker.date;
    } else {
        self.recoveryDate.text = [self.formatter stringFromDate:picker.date];
        self.injury.dor = picker.date;
    }
}

#pragma mark - === Availability Picker === -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([self.site isFirstResponder]) {
        self.site.text = self.siteLabels[row];
        self.injury.site = self.siteLabels[row];
    } else {
        if (row == 0)
            self.injury.status = @(InjuryStatusTypeOut);
        else if (row == 1)
            self.injury.status = @(InjuryStatusTypePractice);
        else
            self.injury.status = @(InjuryStatusTypeOK);
        self.availability.text = [InjuryStatus textForStatus:self.injury.status];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([self.site isFirstResponder])
        return 4;
    else
        return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([self.site isFirstResponder]) {
        return self.siteLabels[row];
    } else {
        if (row == 0)
            return [InjuryStatus textForStatus:@(InjuryStatusTypeOut)];
        else if (row == 1)
            return [InjuryStatus textForStatus:@(InjuryStatusTypePractice)];
        else
            return [InjuryStatus textForStatus:@(InjuryStatusTypeOK)];
    }
}

#pragma mark - === Keyboard Notifications === -

- (void)keyboardWillShow:(NSNotification *)notification {
    const NSDictionary *const userInfo = [notification userInfo];
    
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    self.bottomViewConstraint.constant = CGRectGetHeight(keyboardRect);
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    const NSDictionary *const userInfo = [notification userInfo];
    
    self.bottomViewConstraint.constant = 0;
    [self.view setNeedsUpdateConstraints];
    
    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - === Segue === -

#define VALIDATE(var, str) NSString *var = [self.var.text stringByTrimmingCharactersInSet:ws]; if (var.length == 0) { [BlockAlertView okWithMessage:str]; return; }

- (IBAction)doneButtonPressed:(id)sender {
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    VALIDATE(site, NSLocalizedString(@"INJURY_EDITOR_MISSING_SITE", @"Warning to display when the site of the injury is missing."));
    VALIDATE(details, NSLocalizedString(@"INJURY_EDITOR_MISSING_DETAILS", @"Warning to display when the details of the injury are missing"));
    
    self.injury.site = self.site.text;
    self.injury.details = self.details.text;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInjuryChangedNotification object:self userInfo:@{kInjuryChangedValue : self.injury.status}];
    
    NSManagedObjectContext *importContext = self.childContext;
    NSManagedObjectContext *context = self.person.managedObjectContext;
    
    __typeof__(self) __weak weakSelf = self;

    [[WebServer sharedInstance] addOrUpdateInjuryStatus:self.injury success:^(const NSArray *const data) {
        NSNumber *ident = [data firstObject];

        __typeof__(self) __strong strongSelf = weakSelf;

        if (ident) {
            [importContext performBlockAndWait:^{
                strongSelf.injury.sql_ident = ident;
                
                NSError *error = nil;
                if (![importContext save:&error])
                    NSLog(@"1. %s: %@", __func__, error);
                else
                    [context performBlock:^{
                        NSError *e2 = nil;
                        if (![context save:&e2])
                            NSLog(@"2. %s: %@", __func__, e2);
                    }];
            }];
        }
        
        [strongSelf performSegueWithIdentifier:@"injuryEditDone" sender:self];
    } failure:nil];
}

@end
