//
//  SettingsProfile3ViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 4/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "SettingsProfile3ViewController.h"
#import "SettingsProfile4ViewController.h"
#import "UITextView+VisibleBorder.h"

@interface SettingsProfile3ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *address;
@end

@implementation SettingsProfile3ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addressLabel.text = NSLocalizedString(@"PROFILE_ADDRESS_LABEL", @"Label asking for address.");

    self.address.text = self.person.address;
    self.address.keyboardType = UIKeyboardTypeASCIICapable;
    self.address.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.address.autocorrectionType = UITextAutocorrectionTypeNo;

    [self.address showBorder];
}

#pragma mark - === Segues === -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ps4"]) {
        [self.editContext performBlockAndWait:^{
            self.person.address = [self.address.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }];
        
        SettingsProfile4ViewController *vc = [segue realDestinationViewController];
        vc.editContext = self.editContext;
        vc.person = self.person;
    }
}

@end
