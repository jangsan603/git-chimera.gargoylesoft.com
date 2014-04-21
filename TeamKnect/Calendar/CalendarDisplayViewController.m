//
//  CalendarDisplayViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/14/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarDisplayViewController.h"
#import "GSEventEditorViewController.h"
#import "CalendarMonthViewController.h"
#import "CalendarListViewController.h"
#import "GSRevealViewController.h"
#import "CalendarMap+Category.h"
#import "CalendarMapExtras.h"
#import "UIView+Category.h"
#import "EKEvent+rfc2445.h"
#import "Person.h"
#import "Team.h"

@interface CalendarDisplayViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) CalendarMonthViewController *monthViewController;
@property (nonatomic, strong) CalendarListViewController *listViewController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSDate *dateBeingDisplayed;
@property (nonatomic, copy) NSArray *priorConstraints;
@property (nonatomic, assign) BOOL belongsToTeam;
@end

@implementation CalendarDisplayViewController

- (void)viewDidLoad
{
//    NSLog(@"%s loading", __func__);
    [super viewDidLoad];

    self.belongsToTeam = NO;
    self.dateBeingDisplayed = [NSDate date];

    self.navigationController.navigationBar.translucent = NO;

    if (self.team)
        self.managedObjectContext = self.team.managedObjectContext;
    else
        self.managedObjectContext = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
    
    __typeof__(self) __weak weakSelf = self;

    [[NSNotificationCenter defaultCenter] addObserverForName:kSelectedDateChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        weakSelf.dateBeingDisplayed = note.object;
    }];
    
    if (self.team)
        self.navigationItem.title = self.team.name;
    else
        [self setMyNameInNavigationTitle:nil];
    
    UIBarButtonItem *viewType = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ViewType"] style:UIBarButtonItemStylePlain target:self action:@selector(displayTypeButtonPressed:)];
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MenuBar"] style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonPressed)];
    self.navigationItem.leftBarButtonItems = @[menu, viewType];
    
    // Since it's done via view containment, we can't scroll under the nav bar.
    self.edgesForExtendedLayout = UIRectEdgeNone;

    int type = [[[NSUserDefaults standardUserDefaults] valueForKey:@"cal_display_preference"] intValue];
    if (type == 0)
        [self showByDay];
    else
        [self showByMonth];
    
    self.canDisplayBannerAds = YES;
}

- (void)removeChildrenContainers:(UIViewController *)vc {
    if (!vc)
        return;
    
    [vc willMoveToParentViewController:nil];
    [vc removeFromParentViewController];
    
    if (self.priorConstraints)
        [vc.view removeConstraints:self.priorConstraints];
    
    [vc.view removeFromSuperview];
}

- (void)dealloc {   
    [self removeChildrenContainers:self.monthViewController];
    [self removeChildrenContainers:self.listViewController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMyNameInNavigationTitle:(NSNumber *)me {
    if (self.team)
        return;
    
    if (!me)
        me = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    request.propertiesToFetch = @[@"last"];
    request.predicate = [NSPredicate predicateWithFormat:@"sql_ident = %@", me];
    
    const NSArray *const ary = [self.managedObjectContext executeFetchRequest:request error:NULL];
    const Person *const person = [ary firstObject];
    self.navigationItem.title = person.last;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"me"])
        [self performSegueWithIdentifier:@"register" sender:nil];
}

- (IBAction)displayTypeButtonPressed:(UIBarButtonItem *)sender {
    NSString *const byMonth = NSLocalizedString(@"CALENDAR_VIEW_BY_MONTH", @"Choice to view the calendar in a month display.");
    NSString *const byDay = NSLocalizedString(@"CALENDAR_VIEW_BY_DAY", @"Choice to view the calendar in a day display.");
    NSString *const today = NSLocalizedString(@"CALENDAR_VIEW_GOTO_TODAY", @"Choice to jump to today in the calendar");
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"CALENDAR_VIEW_DISPLAY_TITLE", @"Title asking what type of calendar view they want")
                                                       delegate:self
                                              cancelButtonTitle:kCancelButton
                                         destructiveButtonTitle:nil otherButtonTitles:byDay, byMonth, today, nil];
    [sheet showFromBarButtonItem:sender animated:YES];
}

- (void)menuButtonPressed {
    [[NSNotificationCenter defaultCenter] postNotificationName:GSRevealViewControllerToggleLeftViewController object:self];
}

#pragma mark - === Action Sheet === -

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;
    else if (buttonIndex == 0)
        [self showByDay];
    else if (buttonIndex == 1)
        [self showByMonth];
    else {
        self.dateBeingDisplayed = [NSDate date];
        [[NSNotificationCenter defaultCenter] postNotificationName:kJumpToSpecificDayNotification object:self userInfo:@{kJumpToSpecificDayValue : [NSDate date]}];
    }
}

#pragma mark - === Segues === -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"addEvent"] == NO || self.belongsToTeam)
        return YES;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Team"];
    request.fetchLimit = 1;
    
    NSArray *ary = [self.managedObjectContext executeFetchRequest:request error:NULL];
    if (ary.count) {
        self.belongsToTeam = YES;
        return YES;
    }
    
    [BlockAlertView okWithMessage:NSLocalizedString(@"CALENDAR_JOIN_TEAM_FIRST", @"Message stating they can't create calendar item until they're on a team.")];
    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addEvent"]) {
        GSEventEditorViewController *vc = [segue realDestinationViewController];
        vc.team = self.team;
        vc.initialDate = self.dateBeingDisplayed;
    }
}

- (IBAction)calendarEditorCancelButtonPressed:(UIStoryboardSegue *)sender {
    
}

- (IBAction)calendarEditorDeleteButtonPressed:(UIStoryboardSegue *)sender {
    @try {
        GSEventEditorViewController *vc = [sender sourceViewController];
        
        CalendarEventStore *store = [CalendarEventStore sharedInstance];
        
        NSError *error;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CalendarMap"];
        request.predicate = [NSPredicate predicateWithFormat:@"eventIdentifier = %@", vc.event.eventIdentifier];
        
        // They might create an event outside of the application, directly in their calendar.  If that happens
        // then map is going to come back nil.  We still need to do the rest of the method though as we need
        // to actually delete the calendar events.  We just don't try and contact the server at that point.
        CalendarMap *map = [[self.managedObjectContext executeFetchRequest:request error:NULL] firstObject];
        
        if (!map) {
            // The event being deleted isn't a toplevel item.  Is it a one-off?
            request = [[NSFetchRequest alloc] initWithEntityName:@"CalendarMapExtras"];
            request.predicate = [NSPredicate predicateWithFormat:@"eventIdentifier = %@", vc.event.eventIdentifier];
            CalendarMapExtras *extras = [[self.managedObjectContext executeFetchRequest:request error:NULL] firstObject];
            
            if (extras) {
                map = extras.calendarMap;
                
                if (vc.span == EKSpanFutureEvents) {
                    for (CalendarMapExtras *e in map.extras) {
                        if ([e.date compare:vc.event.startDate] == NSOrderedAscending)
                            continue;
                        
                        // e's event is the same day or later than the event we deleted
                        EKEvent *eventToDelete = [store eventWithIdentifier:e.eventIdentifier];
                        if (eventToDelete) {
                            error = nil;
                            if (![store removeEvent:eventToDelete span:EKSpanFutureEvents error:&error] && error)
                                NSLog(@"Failed to remove extras event: %@", error);
                        }
                        
                        [self.managedObjectContext deleteObject:e];
                    }
                } else {
                    EKEvent *eventToDelete = [store eventWithIdentifier:extras.eventIdentifier];
                    if (eventToDelete) {
                        [map addExceptionDate:eventToDelete];

                        error = nil;
                        if (![store removeEvent:eventToDelete span:EKSpanThisEvent error:&error] && error)
                            NSLog(@"Failed to remove extras event: %@", error);
                    }
                    
                    [self.managedObjectContext deleteObject:extras];
                }

                if (![self.managedObjectContext save:&error])
                    NSLog(@"%s: SAVE: %@", __func__, error);

                // Deleting a one-off means we have to always rewrite the master event.
                EKEvent *master = [store eventWithIdentifier:map.eventIdentifier];
                if (master)
                    [[WebServer sharedInstance] saveCalendarItem:master forTeam:vc.team calendarMap:map rebuildString:YES success:nil failure:nil];
                                
                return;
            }
        }
        
        EKEvent *eventToDelete = vc.event;
        EKEvent *master = (EKEvent *) [store eventWithIdentifier:eventToDelete.eventIdentifier];
        
        if (vc.span == EKSpanFutureEvents) {
            if (map) {
                // Make sure we delete any one-off objects
                for (CalendarMapExtras *e in map.extras) {
                    if ([e.date compare:vc.event.startDate] == NSOrderedAscending)
                        continue;
                    
                    // e's event is the same day or later than the event we deleted
                    EKEvent *toDelete = [store eventWithIdentifier:e.eventIdentifier];
                    if (toDelete) {
                        error = nil;
                        if (![store removeEvent:toDelete span:EKSpanFutureEvents error:&error] && error)
                            NSLog(@"Failed to remove extras event: %@", error);
                    }
                    
                    [self.managedObjectContext deleteObject:e];
                }
            }
            
            if ([master compareStartDateWithEvent:eventToDelete] == NSOrderedSame) {
                // We are deleting the entire series
                if (map)
                    [self.managedObjectContext deleteObject:map];
                
                [store removeEvent:master span:EKSpanFutureEvents error:NULL];
                
                if (map)
                    [[WebServer sharedInstance] deleteCalendarItem:map.sql_ident success:nil failure:nil];
            } else {
                // We are deleting from this point forwards.
                [store removeEvent:eventToDelete span:EKSpanFutureEvents error:NULL];
                
                if (map)
                    [[WebServer sharedInstance] saveCalendarItem:master forTeam:vc.team calendarMap:map rebuildString:YES success:nil failure:nil];
            }
        } else {
            // We are deleting a single item.
            if (![store removeEvent:vc.event span:EKSpanThisEvent error:&error])
                TFLog(@"%s: Single: %@ --- %@", __func__, error, vc.event);
            
            if (map) {
                [map addExceptionDate:vc.event];
                
                [[WebServer sharedInstance] saveCalendarItem:master forTeam:vc.team calendarMap:map rebuildString:YES success:nil failure:nil];
            }
        }
        
        if (![self.managedObjectContext save:&error])
            NSLog(@"%s: SAVE: %@", __func__, error);
    } @catch (NSException *ex) {
        [BlockAlertView okWithTitle:@"Delete Exception" message:ex.reason];
    }
}

- (IBAction)calendarEditorDoneButtonPressed:(UIStoryboardSegue *)sender {
    GSEventEditorViewController *vc = [sender sourceViewController];

    CalendarEventStore *store = [CalendarEventStore sharedInstance];
    
    if (!(vc.changedSomething || vc.isNewlyCreatedEvent))
        return;
    
    NSError *error;
    
    if (vc.isNewlyCreatedEvent) {
        if (![store saveEvent:vc.event span:vc.span error:&error])
            NSLog(@"%s: %@", __func__, error);
        
        [[WebServer sharedInstance] saveCalendarItem:vc.event forTeam:vc.team calendarMap:nil rebuildString:NO success:nil failure:^(NSError *error) {
            [BlockAlertView okWithMessage:[LocalizedStrings tryLater]];
        }];
        
        return;
    }
    
    // Modifying existing events is the harder part!
    EKEvent *master = (EKEvent *) [store eventWithIdentifier:vc.event.eventIdentifier];
    
    if (vc.span == EKSpanFutureEvents) {
        // We have to actually create a new event apparently
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.calendar = vc.event.calendar;
        event.title = vc.event.title;
        event.location = vc.event.location;
        event.notes = vc.event.notes;
        event.URL = vc.event.URL;
        event.startDate = vc.event.startDate;
        event.endDate = vc.event.endDate;
        event.recurrenceRules = vc.event.recurrenceRules;
        event.allDay = vc.event.allDay;
        event.timeZone = vc.event.timeZone;
        
        if (![store saveEvent:event span:EKSpanFutureEvents error:&error])
            NSLog(@"%s: SE: %@", __func__, error);

        // Now create the calendar map for this new event
        CalendarMap *map = [NSEntityDescription insertNewObjectForEntityForName:@"CalendarMap" inManagedObjectContext:self.managedObjectContext];
        map.eventIdentifier = event.eventIdentifier;
        map.uid = [EKEvent uid];
        map.rfc2445 = [event toRfc2445WithUID:map.uid];
        map.sql_ident = @0;
        map.team = self.team ? self.team : vc.team;
        
        // Then save the new event
        [[WebServer sharedInstance] saveCalendarItem:event forTeam:vc.team calendarMap:map rebuildString:NO success:nil failure:nil];
        
        if ([master.startDate isEqualToDate:event.startDate]) {
            // If we edited the master, we have to call delete, not save, otherwise we duplicate as we wrote 'event' already
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CalendarMap"];
            request.predicate = [NSPredicate predicateWithFormat:@"eventIdentifier = %@", master.eventIdentifier];
            const NSArray *const items = [self.managedObjectContext executeFetchRequest:request error:NULL];
            const CalendarMap *const map = [items firstObject];

            if (map)
                [[WebServer sharedInstance] deleteCalendarItem:map.sql_ident success:nil failure:nil];
            
            if (![store removeEvent:master span:EKSpanFutureEvents error:&error])
                NSLog(@"%s: RE: %@", __func__, error);
        } else {
            // If we didn't edit the master, then save out its new configuration now.
            if (![store removeEvent:vc.event span:EKSpanFutureEvents error:&error])
                NSLog(@"%s: RE: %@", __func__, error);

            // And then update the webserver afterwards
            [[WebServer sharedInstance] saveCalendarItem:master forTeam:vc.team calendarMap:nil rebuildString:YES success:nil failure:nil];
        }
    } else {
        // Grab a pointer to the CalendarMap object so we can find the 'extras'
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CalendarMap"];
        request.predicate = [NSPredicate predicateWithFormat:@"eventIdentifier = %@", vc.event.eventIdentifier];
        
        const NSArray *values = [self.managedObjectContext executeFetchRequest:request error:NULL];
        CalendarMap *map = [values firstObject];
        
        BOOL eventIsRecurring = vc.event.recurrenceRules.count > 0;
        
        // A one-off edit may not have recurrence rules on it.
        
        vc.event.recurrenceRules = nil;
        
        if (![store saveEvent:vc.event span:EKSpanThisEvent error:&error] && error)
            NSLog(@"%s: EKSpanThisEvent %@", __func__, error);
        
        if (eventIsRecurring) {
            // Now we need to find the existing CalendarMapExtras for this object, if it actually exists.  If it does
            // exist we just rewrite it and up the sequence number by 1.  If not, we write it and set the sequence to 1
            request = [[NSFetchRequest alloc] initWithEntityName:@"CalendarMapExtras"];
            request.predicate = [NSPredicate predicateWithFormat:@"calendarMap = %@ AND date = %@", map, vc.initialDate];
            
            CalendarMapExtras *extra = [[self.managedObjectContext executeFetchRequest:request error:NULL] firstObject];
            if (extra) {
                extra.sequence = @([extra.sequence integerValue] + 1);
            } else {
                extra = [NSEntityDescription insertNewObjectForEntityForName:@"CalendarMapExtras" inManagedObjectContext:self.managedObjectContext];
                extra.sequence = @1;
            }
            
            NSMutableString *str = [[NSMutableString alloc] initWithString:[vc.event toRfc2445WithUID:map.uid]];
            if (master.allDay)
                [str appendFormat:@"\r\nRECURRENCE-ID;VALUE=DATE:%@", [[EKEvent dateOnlyFormatter] stringFromDate:vc.initialDate]];
            else
                [str appendFormat:@"\r\nRECURRENCE-ID:%@", [[EKEvent dateAndTimeFormatter] stringFromDate:vc.initialDate]];
            
            extra.eventIdentifier = vc.event.eventIdentifier;
            extra.rfc2445 = str;
            extra.calendarMap = map;
            extra.date = vc.event.startDate;
            
            if (![self.managedObjectContext save:&error])
                NSLog(@"%s: %@", __func__, error);
        } else {
            // This event really is the master event at this point, so save this one instead.
            master = vc.event;
        }
        
        [[WebServer sharedInstance] saveCalendarItem:master forTeam:vc.team calendarMap:map rebuildString:YES success:nil failure:^(NSError *error) {
            [BlockAlertView okWithMessage:[LocalizedStrings tryLater]];
        }];
    }
}

- (void)show:(UIViewController __strong **)show hide:(UIViewController __strong **)hide ident:(NSString *)ident {
    if (*show)
        return;

    if (*hide) {
        if (self.priorConstraints)
            [(*hide).view removeConstraints:self.priorConstraints];
        
        [(*hide).view removeFromSuperview];
        [*hide willMoveToParentViewController:nil];
        [*hide removeFromParentViewController];
        *hide = nil;
    }

    *show = [self.storyboard instantiateViewControllerWithIdentifier:ident];

    id<CalendarDisplayProtocol> vc = (id<CalendarDisplayProtocol>) *show;
    vc.managedObjectContext = self.managedObjectContext;
    vc.team = self.team;

    [self addChildViewController:*show];
    [self.view addSubview:(*show).view];
    [*show didMoveToParentViewController:self];
    
    self.priorConstraints = [(*show).view constrainMeToMatchSuperview:self.view];
}

- (void)showByDay {
    [self show:&_listViewController hide:&_monthViewController ident:@"teamCalendarList"];
}

- (void)showByMonth {
    [self show:&_monthViewController hide:&_listViewController ident:@"teamCalendarMonth"];
}


@end
