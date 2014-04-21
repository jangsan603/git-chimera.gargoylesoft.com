//
//  GSEventEditorViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/27/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSEventEditorViewController.h"
#import "GSEventEditorTypePickerViewController.h"
#import "GSEventEditorRepeatEndViewController.h"
#import "GSEventEditorRepeatViewController.h"
#import "GSCalendarListViewController.h"
#import "GSEventEditorDatePickerCell.h"
#import "GSEventEditorAllDayCell.h"
#import "GSEventEditorDeleteCell.h"
#import "GSEventEditorNotesCell.h"
#import "GSEventEditorTextCell.h"
#import "Team+Category.h"
#import "AppDelegate.h"

static const NSInteger kTypeSection = 0;
static const NSInteger kTitleSection = 1;
static const NSInteger kDateSection = 2;
static const NSInteger kRepeatSection = 3;
static const NSInteger kVariableSection = 4;

static const NSInteger kRecurrenceAlert = 10;
static const NSInteger kRecurrenceOnlyAlert = 11;
static const NSInteger kDeleteAlert = 12;

@interface GSEventEditorViewController () <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>
@property (nonatomic, unsafe_unretained) NSInteger notesSection, calendarSection, deleteSection;
@property (nonatomic, unsafe_unretained) CGFloat pickerCellRowHeight;
@property (nonatomic, unsafe_unretained) BOOL canEditCalendarChoice;
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIView *firstResponder;
@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, copy) NSString *eventType;
@property (nonatomic, copy) NSString *updatedTitle, *updatedNotes, *updatedURL, *updatedLocation, *recurrenceText;
@property (nonatomic, strong) NSDate *updatedStart, *updatedEnd;
@property (nonatomic, copy) NSDate *initialPickerDate;
@property (nonatomic, assign) BOOL updatedAllDay, changedAllDayValue;
@property (nonatomic, strong) EKCalendar *updatedCalendar;
@property (nonatomic, assign) EKRecurrenceFrequency updatedRecurrenceFrequency;
@property (nonatomic, assign) NSInteger updatedRecurrencyInterval;
@property (nonatomic, copy) NSDate *updatedRecurrencyEnd;
@property (nonatomic, assign) BOOL recurring;
@end

@implementation GSEventEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"datePicker"];
    self.pickerCellRowHeight = CGRectGetHeight(cell.frame);

    [[NSNotificationCenter defaultCenter] addObserverForName:NSCurrentLocaleDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        // If the locale changed, then the date/time format has to be updated.
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kDateSection] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    if (!self.event) {
        self.event = [EKEvent eventWithEventStore:[CalendarEventStore sharedInstance]];
        
        const NSCalendar *const calendar = [NSCalendar autoupdatingCurrentCalendar];
        const NSUInteger wanted = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour;
        NSDateComponents *components = [calendar components:wanted fromDate:self.initialDate];

        self.event.startDate = [calendar dateFromComponents:components];

        components = [[NSDateComponents alloc] init];
        components.hour = 1;

        self.event.endDate = [calendar dateByAddingComponents:components toDate:self.event.startDate options:0];

        self.calendarSection = kVariableSection;
        self.notesSection = kVariableSection + 1;
        self.deleteSection = 99;
        
        self.calendars = [[CalendarEventStore sharedInstance] calendarsForEntityType:EKEntityTypeEvent];
        
        // TODO: This is causing it to ALWAYS save the item, even on no changes.
        if (self.team)
            self.updatedCalendar = [self.team calendarForTeam];
        
        self.isNewlyCreatedEvent = YES;
    } else {
        self.calendarSection = 99;
        self.notesSection = kVariableSection;
        self.deleteSection = kVariableSection + 1;

        if (self.event.hasNotes) {
            const NSRegularExpression *const regex = [[NSRegularExpression alloc] initWithPattern:@"^TeamKnect TYPE:\\s*(.*)$" options:NSRegularExpressionAnchorsMatchLines error:NULL];
            const NSArray *const matches = [regex matchesInString:self.event.notes options:0 range:NSMakeRange(0, self.event.notes.length)];
            const NSTextCheckingResult *const match = [matches firstObject];
            if (match) {
                self.eventType = [self.event.notes substringWithRange:[match rangeAtIndex:1]];
            }
        }
        
        // TODO: This is causing it to ALWAYS save the item, even on no changes.
        self.updatedCalendar = self.event.calendar;
        self.isNewlyCreatedEvent = NO;
        
        self.initialDate = self.event.startDate;
    }
    
    if (self.event.hasRecurrenceRules) {
        EKRecurrenceRule *rule = [self.event.recurrenceRules firstObject];
        switch (rule.frequency) {
            case EKRecurrenceFrequencyDaily:
                self.recurrenceText = [LocalizedStrings repeatDaily];
                break;
            case EKRecurrenceFrequencyWeekly:
                self.recurrenceText = rule.interval > 1 ? [LocalizedStrings repeatEveryTwoWeeks] : [LocalizedStrings repeatWeekly];
                break;
            case EKRecurrenceFrequencyMonthly:
                self.recurrenceText = [LocalizedStrings repeatMonthly];
                break;
            case EKRecurrenceFrequencyYearly:
                self.recurrenceText = [LocalizedStrings repeatYearly];
                break;
        }
        
        if (rule.recurrenceEnd)
            self.updatedRecurrencyEnd = rule.recurrenceEnd.endDate;
        
        self.updatedRecurrencyInterval = rule.interval;
        self.updatedRecurrenceFrequency = rule.frequency;
        
        self.recurring = YES;
    } else {
        self.recurrenceText = [LocalizedStrings repeatNone];
        self.recurring = NO;
    }
    
    self.updatedAllDay = self.event.allDay;
    self.updatedStart = self.event.startDate;
    self.updatedEnd = self.event.endDate;
    
    if (self.team == nil) {
        NSFetchRequest *const request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
        request.predicate = [NSPredicate predicateWithFormat:@"calendarIdentifier != nil"];
        request.propertiesToFetch = @[@"calendarIdentifier"];
        
        NSManagedObjectContext *moc = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
        const NSArray *const teams = [moc executeFetchRequest:request error:NULL];
        if (teams.count == 1) {
            self.team = [teams firstObject];
            self.event.calendar = self.updatedCalendar = [self.team calendarForTeam];
            self.canEditCalendarChoice = NO;
        } else
            self.canEditCalendarChoice = YES;
    } else {
        self.event.calendar = [self.team calendarForTeam];
        self.canEditCalendarChoice = NO;
        self.navigationItem.title = self.team.name;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSCurrentLocaleDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    self.dateFormatter = nil;
    [super didReceiveMemoryWarning];
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter != nil)
        return _dateFormatter;

    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    _dateFormatter.timeStyle = self.updatedAllDay ? NSDateFormatterNoStyle : NSDateFormatterShortStyle;

    return _dateFormatter;
}

#pragma mark - === Date Picker Helper Methods === -

- (BOOL)cellAtIndexPathHasDatePickerChild:(const NSIndexPath *const)indexPath {
    NSIndexPath *const nextRow = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    return [nextRow isEqual:self.datePickerIndexPath];
}

- (BOOL)cellAtIndexPathHasDatePicker:(const NSIndexPath *const)indexPath {
    return [self.datePickerIndexPath isEqual:indexPath];
}

- (void)displayDatePickerInlineForRowAtIndexPath:(const NSIndexPath *const)indexPath {
    [self.tableView beginUpdates];

    const BOOL justHide = [self cellAtIndexPathHasDatePickerChild:indexPath];

    if (self.datePickerIndexPath) {
        [self.tableView deleteRowsAtIndexPaths:@[self.datePickerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.datePickerIndexPath = nil;
    }

    if (!justHide) {
        // If we tapped the first row, then we're adding the dropdown to the start date, which is
        // always index 2.  If we tapped anything else, we're adding the dropdown to the end date,
        // meaning it would become 3.
        NSInteger row = indexPath.row == 1 ? 2 : 3;

        self.datePickerIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
        [self.tableView insertRowsAtIndexPaths:@[self.datePickerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    [self.tableView endUpdates];

    if (!justHide) {
        // This has to be done *after* the call to endUpdates or the cell won't really exist yet.
        GSEventEditorDatePickerCell *cell = (GSEventEditorDatePickerCell *) [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        [cell.picker setDate:self.datePickerIndexPath.row == 2 ? self.updatedStart : self.updatedEnd animated:YES];
    }
}

- (BOOL)isStartDatePicker {
    return self.datePickerIndexPath.section == kDateSection && self.datePickerIndexPath.row == 2;
}

// This should really be in the cell, with a callback...
- (IBAction)datePickerValueChanged:(const UIDatePicker *const)picker {
    if ([self isStartDatePicker]) {
        const NSUInteger wanted = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        const NSCalendar *const calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *const components = [calendar components:wanted fromDate:self.initialPickerDate toDate:picker.date options:0];
        
        self.updatedStart = picker.date;
        self.updatedEnd = [calendar dateByAddingComponents:components toDate:self.updatedEnd options:0];
    } else {
        self.updatedEnd = picker.date;
    }

    const NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:self.datePickerIndexPath.section];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - === Table View === -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;

    if (section == kTitleSection) {
        GSEventEditorTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
        cell.text.delegate = self;
        cell.text.keyboardType = UIKeyboardTypeDefault;
        cell.text.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        cell.text.autocorrectionType = UITextAutocorrectionTypeYes;
        cell.accessoryType = UITableViewCellAccessoryNone;

        if (row == 0) {
            cell.text.placeholder = NSLocalizedString(@"CALENDAR_TITLE_PLACEHOLDER", @"Placeholder text for the title of the calendar event.");
            cell.text.text = self.updatedTitle ? self.updatedTitle : self.event.title;
        } else if (row == 1) {
            cell.text.placeholder = NSLocalizedString(@"CALENDAR_LOCATION_PLACEHOLDER", @"Placeholder text for the location of the calendar event.");
            cell.text.text = self.updatedLocation ? self.updatedLocation : self.event.location;
        }

        return cell;
    } else if (section == kDateSection) {
        if (row == 0) {
            GSEventEditorAllDayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allDay" forIndexPath:indexPath];
            [cell.toggle setOn:self.updatedAllDay animated:NO];
            cell.onToggle = ^(BOOL isOn) {
                self.updatedAllDay = isOn;
                self.changedAllDayValue = isOn != self.event.allDay;
                
                // The style needs to change
                self.dateFormatter = nil;
                
                // Both dates need to be redisplayed, as well as the picker, if it exists.
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kDateSection] withRowAnimation:UITableViewRowAnimationNone];
            };
            
            return cell;
        } else if ([self cellAtIndexPathHasDatePicker:indexPath]) {
            GSEventEditorDatePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"datePicker" forIndexPath:indexPath];
            cell.picker.datePickerMode = self.updatedAllDay ? UIDatePickerModeDate : UIDatePickerModeDateAndTime;

            if (row == 2)
                [cell.picker setDate:self.updatedStart animated:NO];
            else
                [cell.picker setDate:self.updatedEnd animated:NO];

            self.initialPickerDate = cell.picker.date;
            
            cell.accessoryType = UITableViewCellAccessoryNone;

            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetail" forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;

            if (row == 1) {
                cell.textLabel.text = NSLocalizedString(@"START_DATE_LABEL", @"The label for the start of the calendar event date.");
                cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.updatedStart];
            } else {
                cell.textLabel.text = NSLocalizedString(@"END_DATE_LABEL", @"The label for the end of the calendar event date.");
                cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.updatedEnd];
            }

            return cell;
        }
    } else if (section == kTypeSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetail"];
        cell.textLabel.text = NSLocalizedString(@"CALENDAR_TYPE_LABEL", @"The label for the type of calendar event this is.");
        cell.detailTextLabel.text = self.eventType;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        return cell;
    } else if (section == kRepeatSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetail"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString(@"CALENDAR_REPEAT_LABEL", @"The label for the repeat type of the event.");
            cell.detailTextLabel.text = self.recurrenceText;
        } else {
            cell.textLabel.text = NSLocalizedString(@"CALENDAR_END_REPEAT_LABEL", @"The label for the end repeat date of the event.");
            
            if (self.updatedRecurrencyEnd)
                cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.updatedRecurrencyEnd dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
            else
                cell.detailTextLabel.text = [LocalizedStrings repeatEndNever];
        }
        
        return cell;
    } else if (section == self.notesSection) {
        if (row == 0) {
            GSEventEditorTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
            cell.text.delegate = self;
            cell.text.placeholder = NSLocalizedString(@"CALENDAR_URL_PLACEHOLDER", @"Placeholder text for the URL of the calendar item");
            cell.text.text = self.updatedURL ? self.updatedURL : [self.event.URL absoluteString];
            cell.text.keyboardType = UIKeyboardTypeURL;
            cell.text.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.text.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.accessoryType = UITableViewCellAccessoryNone;

            return cell;
        } else if (row == 1) {
            GSEventEditorNotesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notes" forIndexPath:indexPath];
            cell.textView.text = self.updatedNotes ? self.updatedNotes : self.event.notes;
            cell.accessoryType = UITableViewCellAccessoryNone;

            return cell;
        }
    } else if (section == self.calendarSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetail" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"CALENDAR_CALENDAR_LABEL", @"The label for the calendar to create this event in.");
        cell.detailTextLabel.text = self.updatedCalendar ? self.updatedCalendar.title : @"";

        if (self.canEditCalendarChoice)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;

        return cell;
    } else if (section == self.deleteSection) {
        GSEventEditorDeleteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"delete"];

        cell.onDeleteButtonPressed = ^(CGRect frame) {
            if (self.event.hasRecurrenceRules) {
                NSString *const thisOnly = NSLocalizedString(@"CALENDAR_DELETE_THIS_ONLY", @"Delete only this event");
                NSString *const allFuture = NSLocalizedString(@"CALENDAR_DELETE_FUTURE", @"Delete all future events");

                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"CALENDAR_REPEATING_EVENT_TITLE", @"Message title saying this is a repeating event.")
                                                                   delegate:self
                                                          cancelButtonTitle:kCancelButton
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:thisOnly, allFuture, nil];
                sheet.tag = kDeleteAlert;
                [sheet showFromRect:frame inView:self.view animated:YES];
            } else {
                self.span = EKSpanThisEvent;
                if ([self shouldPerformSegueWithIdentifier:@"deletedCalendaritem" sender:self])
                    [self performSegueWithIdentifier:@"deletedCalendarItem" sender:self];
            }
        };

        return cell;
    }
    
    abort();
}

// This is so that if they type into a text field, and then scroll off screen, we save the values.
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;
    
    if (section == kTitleSection) {
        GSEventEditorTextCell *c = (GSEventEditorTextCell *) cell;
        if (row == 0)
            self.updatedTitle = c.text.text;
        else
            self.updatedLocation = c.text.text;
    } else if (section == self.notesSection) {
        if (row == 0) {
            GSEventEditorTextCell *c = (GSEventEditorTextCell *) cell;
            self.updatedURL = c.text.text;
        } else {
            GSEventEditorNotesCell *c = (GSEventEditorNotesCell *) cell;
            self.updatedNotes = c.textView.text;
        }
    }
    
    // TODO: This method should simply call the did end editing delegate with the textfield
    // so that the logic is in one place.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This is so that if they tap on a date picker the keyboard goes away.
    [self.firstResponder resignFirstResponder];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath isEqual:self.datePickerIndexPath])
        return;

    if (indexPath.section == self.calendarSection) {
        if ([self shouldPerformSegueWithIdentifier:@"chooseCalendar" sender:indexPath])
            [self performSegueWithIdentifier:@"chooseCalendar" sender:indexPath];
    } else if (indexPath.section == kDateSection) {
        if (indexPath.row > 0)
            [self displayDatePickerInlineForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kTypeSection) {
        [self performSegueWithIdentifier:@"chooseType" sender:indexPath];
    } else if (indexPath.section == kRepeatSection) {
        if (indexPath.row == 0) {
            if ([self shouldPerformSegueWithIdentifier:@"chooseRecurrence" sender:indexPath])
                [self performSegueWithIdentifier:@"chooseRecurrence" sender:indexPath];
        } else {
            if ([self shouldPerformSegueWithIdentifier:@"chooseRepeatEnd" sender:indexPath])
                [self performSegueWithIdentifier:@"chooseRepeatEnd" sender:indexPath];
        }
    } else if (indexPath.section == self.deleteSection) {
        GSEventEditorDeleteCell *cell = (GSEventEditorDeleteCell *) [tableView cellForRowAtIndexPath:indexPath];
        if (cell.onDeleteButtonPressed)
            cell.onDeleteButtonPressed(cell.frame);
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.notesSection && indexPath.row == 1)
        return 120.;
    else if (indexPath.section == kDateSection && [self cellAtIndexPathHasDatePicker:indexPath])
        return 216.;
    else
        return self.tableView.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kDateSection) {
        return self.datePickerIndexPath ? 4 : 3;
    } else if (section == kTypeSection ||  section == self.deleteSection || section == self.calendarSection)
        return 1;
    else if (section == kRepeatSection) {
        return self.recurring ? 2 : 1;
    } else
        return 2;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.calendarSection)
        return self.canEditCalendarChoice ? indexPath : nil;
    else
        return indexPath;
}

#pragma mark - === Segue === -

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    if (self.recurring && self.isNewlyCreatedEvent == NO) {
        // If this is a recurring event, but it's not a BRAND NEW recurring event, ask what to save.
        NSString *const thisOnly = NSLocalizedString(@"CALENDAR_SAVE_THIS_ONLY", @"Save only this event");
        NSString *const allFuture = NSLocalizedString(@"CALENDAR_SAVE_FUTURE", @"Save all future events");
        
        UIActionSheet *sheet;
        
        if (self.changedRecurrence || self.changedAllDayValue) {
            sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"CALENDAR_REPEATING_EVENT_TITLE", @"Message title saying this is a repeating event.")
                                                delegate:self
                                       cancelButtonTitle:kCancelButton
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:allFuture, nil];
            sheet.tag = kRecurrenceOnlyAlert;
        } else {
            sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"CALENDAR_REPEATING_EVENT_TITLE", @"Message title saying this is a repeating event.")
                                                delegate:self
                                       cancelButtonTitle:kCancelButton
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:thisOnly, allFuture, nil];
            sheet.tag = kRecurrenceAlert;
        }
        
        [sheet showFromBarButtonItem:sender animated:YES];
    } else if ([self shouldPerformSegueWithIdentifier:@"doneButton" sender:self])
        [self performSegueWithIdentifier:@"doneButton" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chooseCalendar"]) {
        GSCalendarListViewController *vc = [segue destinationViewController];
        vc.onSelect = ^(Team *team, EKCalendar *calendar) {
            [self.navigationController popViewControllerAnimated:YES];
            self.updatedCalendar = calendar;
            self.team = team;
            [self.tableView reloadRowsAtIndexPaths:@[sender] withRowAnimation:UITableViewRowAnimationNone];
        };
    } else if ([segue.identifier isEqualToString:@"chooseRepeatEnd"]) {
        GSEventEditorRepeatEndViewController *vc = [segue destinationViewController];
        vc.date = self.updatedRecurrencyEnd;
        vc.onSelection = ^(NSDate *date) {
            if (self.updatedRecurrencyEnd == nil || ![self.updatedRecurrencyEnd isEqualToDate:date]) {
                self.updatedRecurrencyEnd = date;
                self.changedRecurrence = YES;
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRepeatSection] withRowAnimation:UITableViewRowAnimationNone];
        };
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    [self.firstResponder resignFirstResponder];
    
    if (![identifier isEqualToString:@"doneButton"])
        return YES;

    // They pressed the Done button, so validate everything.
    NSDate *const start = self.updatedStart ? self.updatedStart : self.event.startDate;
    NSDate *const end = self.updatedEnd ? self.updatedEnd : self.event.endDate;
    
    // Note that NSOrderedSame is also actually OK here.
    if ([start compare:end] == NSOrderedDescending) {
        [BlockAlertView okWithMessage:NSLocalizedString(@"DATE_ORDER_WRONG", @"Message stating the start date must come before the end date.")];
        return NO;
    }
    
    NSString *title = self.updatedTitle ? self.updatedTitle : self.event.title;
    if (!title) {
        [BlockAlertView okWithMessage:NSLocalizedString(@"MISSING_CALENDAR_TITLE", @"Message to display when they didn't provide a title for the calendar event.")];
        return NO;
    }

    if (self.event.timeZone == nil) {
        self.event.timeZone = [NSTimeZone localTimeZone];
        self.changedSomething = YES;
    }

    self.event.startDate = start;
    self.event.endDate = end;
    self.event.title = title;
    
    if (!self.updatedCalendar) {
        [BlockAlertView okWithMessage:NSLocalizedString(@"MISSING_TEAM_CALENDAR", @"Message stating that they have to pick a team for the calendar event.")];
        return NO;
    }
        
    self.event.calendar = self.updatedCalendar;

    self.event.allDay = self.updatedAllDay;
    
    if (self.updatedLocation)
        self.event.location = self.updatedLocation;
    
    if (self.updatedNotes)
        self.event.notes = self.updatedNotes;
    
    if (self.updatedURL)
        self.event.URL = [NSURL URLWithString:self.updatedURL];
    
    if (self.recurring) {
        EKRecurrenceEnd *end = nil;
        if (self.updatedRecurrencyEnd)
            end = [EKRecurrenceEnd recurrenceEndWithEndDate:self.updatedRecurrencyEnd];
        
        EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:self.updatedRecurrenceFrequency interval:self.updatedRecurrencyInterval end:end];
        self.event.recurrenceRules = @[rule];
    } else
        self.event.recurrenceRules = nil;
    
    self.changedSomething = self.changedAllDayValue || self.updatedCalendar || self.updatedEnd || self.updatedLocation || self.updatedNotes || self.updatedRecurrenceFrequency || self.updatedRecurrencyEnd || self.updatedRecurrencyInterval || self.updatedStart || self.updatedTitle || self.updatedURL;
    

    return YES;
}

- (IBAction)calendarEventTypeWasSelected:(UIStoryboardSegue *)sender {
    GSEventEditorTypePickerViewController *vc = [sender sourceViewController];
    self.eventType = vc.type;
    
    NSMutableString *fmt = [NSMutableString stringWithFormat:@"TeamKnect TYPE: %@\n", vc.type];
    if (self.updatedNotes)
        [fmt appendString:self.updatedNotes];
    else if (self.event.notes)
        [fmt appendString:self.event.notes];
    
    self.updatedNotes = fmt;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    const NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:0 inSection:kTypeSection];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)calendarRecurrenceTypeWasSelected:(UIStoryboardSegue *)sender {
    GSEventEditorRepeatViewController *vc = [sender sourceViewController];
    
    if (![self.recurrenceText isEqualToString:vc.text]) {
        self.changedRecurrence = YES;
        self.recurrenceText = vc.text;
    }
    
    self.updatedRecurrencyInterval = vc.interval;
    
    if (self.recurring != vc.recurring) {
        self.recurring = vc.recurring;
        self.changedRecurrence = YES;
    }
    
    if (vc.recurring) {
        if (self.updatedRecurrenceFrequency != vc.frequency) {
            self.updatedRecurrenceFrequency = vc.frequency;
            self.changedRecurrence = YES;
        }
        
        if (self.updatedRecurrencyInterval != vc.interval) {
            self.updatedRecurrencyInterval = vc.interval;
            self.changedRecurrence = YES;
        }
    }
        
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRepeatSection] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - === Text Field & Text View === -

/*
 * Keep in mind that if you're in an active text field or text view, and you press
 * a button, the the text field does *not* lose its first responder status.  That is
 * why we have to track who was the first responder here so that when we go to do the
 * shouldPerformSegueWithIdentifier:sender: method we can resign that first responder.
 * Remember also that calling resignFirstResponder does *not* trigger a delegate call.
 */

- (UITableViewCell *)cellForTextField:(const UITextField *const)textField {
    UIView *parent = textField.superview;
    const Class tvc = [UITableViewCell class];

    while (![parent isKindOfClass:tvc])
        parent = parent.superview;

    return (UITableViewCell *)parent;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.firstResponder = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UITableViewCell *const cell = [self cellForTextField:textField];
    const NSIndexPath *const indexPath = [self.tableView indexPathForCell:cell];

    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0)
        text = nil;

    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;

    if (section == kTitleSection) {
        if (row == 0)
            self.updatedTitle = text;
        else
            self.updatedLocation = text;
    } else if (section == self.notesSection && row == 0)
        self.updatedURL = text;

    self.firstResponder = nil;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.firstResponder = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0)
        text = nil;

    self.updatedNotes = text;

    self.firstResponder = nil;
}

#pragma mark - === Action Sheet === -

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;

    self.span = buttonIndex == 0 ? EKSpanThisEvent : EKSpanFutureEvents;
    
    if (actionSheet.tag == kRecurrenceAlert) {
        if ([self shouldPerformSegueWithIdentifier:@"doneButton" sender:self])
            [self performSegueWithIdentifier:@"doneButton" sender:self];
    } else if (actionSheet.tag == kRecurrenceOnlyAlert) {
        self.span = EKSpanFutureEvents;
        
        if ([self shouldPerformSegueWithIdentifier:@"doneButton" sender:self])
            [self performSegueWithIdentifier:@"doneButton" sender:self];
    } else if (actionSheet.tag == kDeleteAlert) {
        if ([self shouldPerformSegueWithIdentifier:@"deletedCalendarItem" sender:self])
            [self performSegueWithIdentifier:@"deletedCalendarItem" sender:self];
    }
}

@end
