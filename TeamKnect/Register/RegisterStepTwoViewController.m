//
//  RegisterStepTwoViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/5/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "RegisterStepTwoViewController.h"
#import "NSManagedObjectContext+CoreDataImport.h"
#import "AccessoryViewToolbar.h"
#import "PhotoPickerDelegate.h"
#import "Person+Category.h"
#import "WebServer.h"
#import "Picture.h"

@interface RegisterStepTwoViewController () <UINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *pwdOne;
@property (weak, nonatomic) IBOutlet UITextField *pwdTwo;
@property (weak, nonatomic) IBOutlet UITextField *dob;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *termsOfUse;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) AccessoryViewToolbar *toolbar;
@property (nonatomic, strong) UIImage *fullSize;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) PhotoPickerDelegate *photoPicker;
@end

@implementation RegisterStepTwoViewController

- (void)setupTextField:(UITextField *)field text:(NSString *)text placeholder:(NSString *)placeholder imageNamed:(NSString *)imageName {
    field.text = text;
    field.placeholder = placeholder;
    field.delegate = self;

    if (imageName) {
        field.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        field.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = -5;

    self.birthday = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];

    self.toolbar = [[AccessoryViewToolbar alloc] initAccessoryView:CGRectGetWidth(self.view.frame)
                                                        textFields:@[self.email, self.firstName, self.lastName, self.pwdOne, self.pwdTwo, self.dob]
                                                      inScrollView:self.scrollView];

    [self setupTextField:self.email text:self.params[@"email"] placeholder:[LocalizedStrings emailPlaceholder] imageNamed:@"registerEmail"];
    [self setupTextField:self.firstName text:nil placeholder:[LocalizedStrings firstNamePlaceholder] imageNamed:@"registerUser"];
    [self setupTextField:self.lastName text:nil placeholder:[LocalizedStrings lastNamePlaceholder] imageNamed:nil];
    [self setupTextField:self.pwdOne text:self.params[@"password"] placeholder:[LocalizedStrings passwordPlaceholder] imageNamed:@"registerLock"];
    [self setupTextField:self.pwdTwo text:nil placeholder:[LocalizedStrings retypePasswordPlaceholder] imageNamed:@"registerLock"];
    [self setupTextField:self.dob
                    text:[NSDateFormatter localizedStringFromDate:self.birthday  dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]
             placeholder:[LocalizedStrings birthdayPlaceholder]
              imageNamed:@"registerBirthday"];

#if DEBUG
    self.pwdTwo.text = @"qqqqqq";
#endif
    
    [self.registerButton setTitle:NSLocalizedString(@"REGISTER_DONE_BUTTON", @"The register button to press on the registration screen")
                         forState:UIControlStateNormal];

    [self.imageButton setTitle:NSLocalizedString(@"REGISTER_IMAGE_BUTTON", @"Title for the button to press to take a picture.") forState:UIControlStateNormal];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.imageButton.enabled = YES;
    } else {
        self.imageButton.enabled = NO;
    }

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.maximumDate = self.birthday;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.date = self.birthday;

    [self.datePicker addTarget:self action:@selector(dateValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.dob.inputView = self.datePicker;

    CGFloat value = 235. / 255.;
    self.view.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1];

    self.registerButton.backgroundColor = [UIColor colorWithRed:9./255. green:116./255. blue:194./255. alpha:1];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.imageButton.backgroundColor = [UIColor colorWithRed:178./255. green:184./255. blue:170./255. alpha:1];

    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"By tapping create you agree to our "];

    NSAttributedString *link = [[NSAttributedString alloc] initWithString:@"Terms of Use" attributes:@{NSLinkAttributeName:[NSURL URLWithString:@"http://www.google.com"]}];
    [str appendAttributedString:link];

    self.termsOfUse.attributedText = str;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.firstName becomeFirstResponder];
}

- (void)dateValueChanged:(UIDatePicker *)picker {
    self.dob.text = [NSDateFormatter localizedStringFromDate:picker.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    self.birthday = picker.date;
}

#pragma mark - === Image Picker === -

- (IBAction)imageButtonPressed:(UIButton *)sender {
    __typeof__(self) __weak weakSelf = self;

    self.photoPicker = [[PhotoPickerDelegate alloc] initWithView:self.view fromViewController:self onImagePicked:^(UIImage *image) {
        if (!image)
            return;
        
        __typeof__(self) __strong strongSelf = weakSelf;

        strongSelf.fullSize = image;
        strongSelf.photoPicker = nil;
    }];

    [self.photoPicker pickImage:sender];
}

#define VALIDATE(var, str) NSString *var = [self.var.text stringByTrimmingCharactersInSet:ws]; if (var.length == 0) { [BlockAlertView okWithMessage:str]; return; }

- (IBAction)registerButtonPressed:(id)sender {
    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];

    VALIDATE(email, [LocalizedStrings emailMissing]);
    VALIDATE(firstName, [LocalizedStrings firstNameMissing]);
    VALIDATE(lastName, [LocalizedStrings lastNameMissing]);
    VALIDATE(pwdOne, [LocalizedStrings passwordMissing]);
    VALIDATE(pwdTwo, [LocalizedStrings passwordMissing]);

    if (![pwdOne isEqualToString:pwdTwo]) {
        [BlockAlertView okWithMessage:NSLocalizedString(@"PASSWORDS_DO_NOT_MATCH", @"Message stating that the two passwords entered are not the same.")];
        return;
    }

    // Webserver is in the US, so must format dates in that format.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";

    // These keys must match what is expected from Person.php on the webserver.
    NSDictionary *params = @{
                             @"email" : email,
                             @"first" : firstName,
                             @"last" : lastName,
                             @"password" : pwdOne,
                             @"dob" : [formatter stringFromDate:self.birthday],
                             @"picture" : self.fullSize ? [UIImagePNGRepresentation(self.fullSize) base64EncodedDataWithOptions:NSDataBase64Encoding76CharacterLineLength] : @"",
                             };

    [[WebServer sharedInstance] registerStepTwo:params
                                        success:^(NSArray *data) {
                                            if (data.count == 0)
                                                return;
                                            
                                            long ident = [data[0] longValue];
                                            
                                            NSManagedObjectContext *context = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
                                            Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
                                            person.sql_ident = @(ident);
                                            person.first = firstName;
                                            person.last = lastName;
                                            person.dob = self.birthday;
                                            person.email = email;

                                            if (self.fullSize)
                                                [person assignImage:self.fullSize];
                                            
                                            [context updateOrInsert:data[1] entityName:@"Sport"];
                                            
                                            NSError *error;
                                            if (![context save:&error]) {
                                                NSLog(@"Failed to create person: %@", error);
                                                abort();
                                            }                                            
                                            
                                            [[NSUserDefaults standardUserDefaults] setValue:@(ident) forKey:@"me"];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:kMeSetNotification object:@(ident)];
                                            
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                        }
                                        failure:^(NSError *error) {
                                            NSLog(@"%@", error);
                                        }];
}

- (IBAction)dobInfoButtonPressed:(id)sender {
    [BlockAlertView okWithMessage:NSLocalizedString(@"WHY_DOB", @"Message explaining we ask for DOB to avoid harrasment.")];
}

#pragma mark - === Text Field === -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.toolbar moveToNextFieldAfter:textField];
    [self.scrollView scrollRectToVisible:self.registerButton.frame animated:YES];
    return YES;
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

    NSTimeInterval animationDuration;
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    self.bottomViewConstraint.constant = 0;
    [self.view setNeedsUpdateConstraints];

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


@end
