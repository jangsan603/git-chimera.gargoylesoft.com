//
//  SettingsProfileViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/22/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsProfileViewController.h"
#import "SettingsProfile2ViewController.h"
#import "AccessoryViewToolbar.h"
#import "PhotoPickerDelegate.h"
#import "Person+Category.h"
#import "Picture.h"

@interface SettingsProfileViewController () <UIScrollViewDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIButton *imagePickerButton;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (nonatomic, strong) AccessoryViewToolbar *toolbar;
@property (nonatomic, strong) PhotoPickerDelegate *photoPicker;
@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) NSManagedObjectContext *editContext;
@property (nonatomic, strong) UIImage *fullPhoto;
@end

@implementation SettingsProfileViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.firstName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.firstName.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.lastName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.lastName.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.email.autocorrectionType = UITextAutocorrectionTypeNo;
    self.email.keyboardType = UIKeyboardTypeEmailAddress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const NSNumber *const me = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"sql_ident = %@", me];
    
    const NSArray *const ary = [self.managedObjectContext executeFetchRequest:request error:NULL];
    NSManagedObjectID *personID = [[ary firstObject] objectID];
    
    self.editContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.editContext.parentContext = self.managedObjectContext;
    self.editContext.undoManager = nil;
    
    [self.editContext performBlockAndWait:^{
        self.person = (Person *) [self.editContext objectWithID:personID];
    }];
    
    self.firstName.text = self.person.first;
    self.lastName.text = self.person.last;
    self.email.text = self.person.email;
    
    self.toolbar = [[AccessoryViewToolbar alloc] initAccessoryView:CGRectGetWidth(self.view.frame)
                                                        textFields:@[self.email, self.firstName, self.lastName, self.phone]
                                                      inScrollView:nil];
    
    [self setupTextField:self.email text:self.person.email placeholder:[LocalizedStrings emailPlaceholder] imageNamed:@"registerEmail"];
    [self setupTextField:self.firstName text:self.person.first placeholder:[LocalizedStrings firstNamePlaceholder] imageNamed:@"registerUser"];
    [self setupTextField:self.lastName text:self.person.last placeholder:[LocalizedStrings lastNamePlaceholder] imageNamed:nil];
    [self setupTextField:self.phone text:self.person.phone placeholder:NSLocalizedString(@"PHONE_NUMBER", @"Placeholder text to enter a phone number.") imageNamed:nil];
    
    if (self.person.thumbnail) {
        UIImage *image = [[UIImage alloc] initWithData:self.person.thumbnail];
        [self.imagePickerButton setImage:image forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.firstName becomeFirstResponder];
}

#pragma mark - === Image Picker === -

- (IBAction)imageButtonPressed:(UIButton *)sender {
    __typeof__(self) __weak weakSelf = self;

    self.photoPicker = [[PhotoPickerDelegate alloc] initWithView:self.view fromViewController:self onImagePicked:^(UIImage *image) {
        if (!image)
            return;
        
        __typeof__(self) __strong strongSelf = weakSelf;
        
        strongSelf.fullPhoto = image;
        [self.editContext performBlockAndWait:^{
            [strongSelf.person assignImage:image];
        }];
        
        [strongSelf.imagePickerButton setImage:[UIImage imageWithData:strongSelf.person.thumbnail] forState:UIControlStateNormal];
    }];
    
    [self.photoPicker pickImage:sender];
}

#pragma mark - === Segues === -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (![identifier isEqualToString:@"ps2"])
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];

    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    VALIDATE(email, [LocalizedStrings emailMissing]);
    VALIDATE(firstName, [LocalizedStrings firstNameMissing]);
    VALIDATE(lastName, [LocalizedStrings lastNameMissing]);
    VALIDATE(phone, NSLocalizedString(@"PHONE_MISSING", @"Message saying to fill in a phone number"));
    
    [self.editContext performBlockAndWait:^{
        self.person.email = email;
        self.person.first = firstName;
        self.person.last = lastName;
        self.person.phone = phone;
        
        if (self.fullPhoto)
            [self.person assignImage:self.fullPhoto];
    }];
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ps2"]) {
        SettingsProfile2ViewController *vc = [segue realDestinationViewController];
        vc.editContext = self.editContext;
        vc.person = self.person;
    }
}

@end
