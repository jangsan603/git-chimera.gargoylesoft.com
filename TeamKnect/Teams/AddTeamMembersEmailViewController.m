//
//  AddTeamMembersEmailViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/13/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "AddTeamMembersEmailViewController.h"
#import "AddressBookPickerViewController.h"
#import "UITextView+VisibleBorder.h"
#import "TeamPerson+Category.h"

@interface AddTeamMembersEmailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addressBookButton;
@property (weak, nonatomic) IBOutlet UIButton *teamButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *instructions;
@property (nonatomic, readwrite, strong) NSArray *emails;
@property (nonatomic, assign) BOOL initialEmailsSet;
@end

@implementation AddTeamMembersEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.initialEmailsSet = NO;
    
    self.navigationItem.title = self.roleName;
    
    self.instructions.text = NSLocalizedString(@"ONE_EMAIL_PER_LINE", @"Instructions telling them to put a single email address per line.");
    self.instructions.numberOfLines = 0;
    
    [self.addressBookButton setTitle:NSLocalizedString(@"ADDRESS_BOOK_BUTTON", @"Text for the button that brings up the address book.") forState:UIControlStateNormal];
    [self.teamButton setTitle:NSLocalizedString(@"TEAM_ADDRESS_BOOK", @"Text for the button that brings up team addresses") forState:UIControlStateNormal];
    
    self.textView.keyboardType = UIKeyboardTypeEmailAddress;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.textView showBorder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.initialEmailsSet || self.initialEmails.count == 0)
        return;
    
    self.initialEmailsSet = YES;
    self.textView.text = [self.initialEmails componentsJoinedByString:@"\n"];
    self.initialEmails = nil;
}

- (NSArray *)names {
    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
    NSMutableSet *set = [NSMutableSet set];

    for (NSString *line in [self.textView.text componentsSeparatedByString:@"\n"]) {
        NSString *str = [line stringByTrimmingCharactersInSet:ws];
        if (str.length == 0)
            continue;
        
        [set addObject:str];
    }
    
    return [set allObjects];
}

#pragma mark - === Segues === -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"cancel"]) {
        self.emails = nil;
    } else if ([identifier isEqualToString:@"done"]) {
        NSArray *ary = [self names];
        if (ary.count == 0) {
            [BlockAlertView okWithMessage:[LocalizedStrings emailMissing]];
            return NO;
        }
        
        self.emails = ary;
    }
    
    return YES;
}

- (IBAction)addressBookCancelButtonPressed:(UIStoryboardSegue *)sender {
    
}

- (IBAction)addressBookDoneButtonPressed:(UIStoryboardSegue *)sender {
    AddressBookPickerViewController *vc = [sender sourceViewController];
    NSArray *ary = [vc selectedEmails];
    if (ary.count == 0)
        return;
    
    // Update the text view to have the new names.
    self.textView.text = [self.textView.text stringByAppendingString:[ary componentsJoinedByString:@"\n"]];
    
    // Then uniquify them and reset the display
    self.textView.text = [[self names] componentsJoinedByString:@"\n"];
}

@end
