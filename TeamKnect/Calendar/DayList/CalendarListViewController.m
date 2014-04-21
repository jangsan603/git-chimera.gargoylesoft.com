//
//  CalendarListViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/26/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarListViewController.h"
#import "CalendarListTableViewController.h"
#import "NSCalendar+LocalizedNames.h"
#import "CalendarWeekdayRowView.h"
#import "NSDate+DateWithoutTime.h"
#import "CalendarListCell.h"
#import "Team.h"

@interface CalendarListViewController () <UIScrollViewDelegate> {
    // This one is going to get looked at repetatively and quickly, so avoid the getter.
    CGFloat offsetToLoadPrevious, offsetToLoadNext;
}
@property (weak, nonatomic) IBOutlet UIScrollView *dayNumberScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *dayDisplayScrollView;
@property (weak, nonatomic) IBOutlet UIView *weekdaySymbolsView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, assign) CGFloat scrollViewPageWidth;
@property (nonatomic, strong) NSMutableArray *dayNumberViews;
@property (nonatomic, strong) NSMutableArray *dayViewControllers;
@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) NSDate *firstWeekday, *lastWeekday;
@property (nonatomic, strong) NSDate *dayBeingViewed;
@end

@implementation CalendarListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    self.dayBeingViewed = [NSDate date];
    
    [self setupScrollingDates];
    [self setupScrollingDays];
    
    // Just to cause the setter to run and do its stuff.  Date has to be set before we have
    // the scrolling stuff, but needs to have the setters run after.
    self.dayBeingViewed = self.dayBeingViewed;
    
    __typeof__(self) __weak weakSelf = self;

    [[NSNotificationCenter defaultCenter] addObserverForName:NSCurrentLocaleDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        // If the locale changed, then the date/time format has to be updated.
        weakSelf.dayBeingViewed = weakSelf.dayBeingViewed;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kJumpToSpecificDayNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        weakSelf.dayBeingViewed = note.userInfo[kJumpToSpecificDayValue];
    }];
    
    self.managedObjectContext = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildWeekdayLabelsWithButtonFrames:(const NSArray *const)frames {
    self.weekdaySymbolsView.backgroundColor = RGB_COLOR(0, 77, 142);
    
    UIImage *img = [[UIImage imageNamed:@"ic_arrow_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.leftButton setImage:img forState:UIControlStateNormal];
    self.leftButton.tintColor = kTintColor;
    
    img = [[UIImage imageNamed:@"ic_arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.rightButton setImage:img forState:UIControlStateNormal];
    self.rightButton.tintColor = kTintColor;
    
    self.dateLabel.textColor = kTintColor;
    
    const NSArray *const symbols = [[NSCalendar currentCalendar] currentLocaleShortWeekdaySymbols];

    const CGFloat size = 10;
    NSLocale *const locale = [NSLocale currentLocale];
    
    for (NSUInteger i = 0; i < symbols.count; i++) {
        const CGFloat x = CGRectGetMidX([frames[i] CGRectValue]) - (size / 2.);

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 5., size, size)];
        label.font = [UIFont boldSystemFontOfSize:12.];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [symbols[i] uppercaseStringWithLocale:locale];
        label.textColor = kTintColor;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.weekdaySymbolsView addSubview:label];
        
        [self.weekdaySymbolsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    }
}

- (void)setupScrollingDates {
    self.scrollViewPageWidth = CGRectGetWidth(self.dayNumberScrollView.frame);

    self.dayNumberScrollView.pagingEnabled = YES;
    self.dayNumberScrollView.showsHorizontalScrollIndicator = NO;
    self.dayNumberScrollView.showsVerticalScrollIndicator = NO;
    self.dayNumberScrollView.contentSize = CGSizeMake(self.scrollViewPageWidth * 3., CGRectGetHeight(self.dayNumberScrollView.frame));
    self.dayNumberScrollView.bounces = NO;

    __typeof__(self) __weak weakSelf = self;

    CalendarWeekdayRowBlock onDateSelected = ^(NSDate *date) {
        weakSelf.dayBeingViewed = date;
    };

    CGRect frame = CGRectMake(0, 0, self.scrollViewPageWidth, CGRectGetHeight(self.dayNumberScrollView.frame));

    // Now calculate the frames for each of the buttons
    const NSInteger numberOfWeekdays = [self.calendar maximumRangeOfUnit:NSCalendarUnitWeekday].length;
    const CGFloat size = 20.;
    CGFloat x = 20.;

    // Screen width minus 40 pixels for left/right edges, minus the width taken up by all the symbols.
    // That's how much space we have to evenly distribute between labels.
    CGFloat spacing = CGRectGetWidth(frame) - (2. * x) - (size * numberOfWeekdays);

    // We have spacings of 1 less than the number of symbols, so divide to get the amount between each.
    spacing /= numberOfWeekdays - 1;

    // And then add in the width of a number
    spacing += size;

    NSMutableArray *buttonFrames = [[NSMutableArray alloc] initWithCapacity:numberOfWeekdays];
    CGRect buttonFrame = CGRectMake(x, (CGRectGetHeight(frame) - size) / 2., size, size);
    for (NSInteger i = numberOfWeekdays - 1; i >= 0; i--) {
        [buttonFrames addObject:[NSValue valueWithCGRect:buttonFrame]];
        buttonFrame = CGRectOffset(buttonFrame, spacing, 0);
    }

    [self buildWeekdayLabelsWithButtonFrames:buttonFrames];

    NSDateComponents *comps = [NSDateComponents new];
    comps.week = -1;

    NSDate *date = [self.calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    comps.week = 1;

    self.dayNumberViews = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 2; i >= 0; i--) {
        CalendarWeekdayRowView *view = [[CalendarWeekdayRowView alloc] initWithCalendar:self.calendar
                                                                                  frame:frame
                                                                           buttonFrames:buttonFrames
                                                                         onDateSelected:onDateSelected];
        [view configureWeekdayNumbersBasedOnDate:date];

        [self.dayNumberViews addObject:view];
        [self.dayNumberScrollView addSubview:view];

        frame = CGRectOffset(frame, self.scrollViewPageWidth, 0);
        date = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    }

    CalendarWeekdayRowView *visible = self.dayNumberViews[1];
    self.firstWeekday = [[visible firstWeekday] dateWithoutTime];
    self.lastWeekday = [[visible lastWeekday] dateWithoutTime];
    
    // Set the delegate AFTER we scroll to where we want to be so that the delegate methods don't run too soon.
    // I'm first setting to nil just in case the delegate gets set in the storyboard.
    self.dayNumberScrollView.delegate = nil;

    CalendarWeekdayRowView *view = self.dayNumberViews[1];
    [self.dayNumberScrollView scrollRectToVisible:view.frame animated:NO];
    self.dayNumberScrollView.delegate = self;
}

- (void)setupScrollingDays {
    self.dayDisplayScrollView.pagingEnabled = YES;
    self.dayDisplayScrollView.showsHorizontalScrollIndicator = NO;
    self.dayDisplayScrollView.showsVerticalScrollIndicator = NO;
    self.dayDisplayScrollView.contentSize = CGSizeMake(self.scrollViewPageWidth * 3., CGRectGetHeight(self.dayDisplayScrollView.frame));
    self.dayDisplayScrollView.bounces = NO;

    CGRect frame = CGRectMake(0, 0, self.scrollViewPageWidth, CGRectGetHeight(self.dayDisplayScrollView.frame));

    NSDateComponents *comps = [NSDateComponents new];
    comps.day = -1;

    NSDate *date = [self.calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    comps.day = 1;

    self.dayViewControllers = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 2; i >= 0; i--) {
        CalendarListTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"calendarListTableView"];
        vc.managedObjectContext = self.managedObjectContext;
        vc.calendar = self.calendar;
        vc.team = self.team;

        // This must be set after team is set as the property setting for dayBeingDisplayed uses the value of team.
        vc.dayBeingDisplayed = date;

        vc.view.frame = frame;

        [self.dayViewControllers addObject:vc];

        frame = CGRectOffset(frame, self.scrollViewPageWidth, 0);
        date = [self.calendar dateByAddingComponents:comps toDate:date options:0];

        [self addChildViewController:vc];
        [self.dayDisplayScrollView addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }

    // Set the delegate AFTER we scroll to where we want to be so that the delegate methods don't run too soon.
    // I'm first setting to nil just in case the delegate gets set in the storyboard.
    self.dayDisplayScrollView.delegate = nil;

    CalendarListTableViewController *vc = self.dayViewControllers[1];
    [self.dayDisplayScrollView scrollRectToVisible:vc.view.frame animated:NO];
    self.dayDisplayScrollView.delegate = self;
}

- (void)setDayBeingViewed:(NSDate *)dayBeingViewed {
    _dayBeingViewed = dayBeingViewed;

    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:dayBeingViewed dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedDateChangedNotification object:dayBeingViewed];
    
    NSDateComponents *components = [NSDateComponents new];
    
    // The visible week row should show the display date, thus the displayDate setter
    CalendarWeekdayRowView *row = self.dayNumberViews[1];
    row.displayDate = self.dayBeingViewed;
    
    // Whereas the previous and next weeks should all just be unselected, so the method
    components.week = -1;
    row = self.dayNumberViews[0];
    [row configureWeekdayNumbersBasedOnDate:[self.calendar dateByAddingComponents:components toDate:self.dayBeingViewed options:0]];
    
    components.week = 1;
    row = self.dayNumberViews[2];
    [row configureWeekdayNumbersBasedOnDate:[self.calendar dateByAddingComponents:components toDate:self.dayBeingViewed options:0]];

    // Now update the list of events for the current day.
    NSDateComponents *comps = [NSDateComponents new];
    comps.day = -1;
    
    NSDate *date = [self.calendar dateByAddingComponents:comps toDate:_dayBeingViewed options:0];
    comps.day = 1;
    
    for (CalendarListTableViewController *const vc in self.dayViewControllers) {
        vc.dayBeingDisplayed = date;
        
        date = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    }
}

#pragma mark - === Date Movement Buttons === -

- (void)updateScrollingDayBeingViewedNumbers:(NSInteger)offset {
    NSDateComponents *components = [NSDateComponents new];
    components.week = offset;
    
    self.dayBeingViewed = [self.calendar dateByAddingComponents:components toDate:self.dayBeingViewed options:0];
}

- (IBAction)leftButtonPressed:(id)sender {
    [self updateScrollingDayBeingViewedNumbers:-1];
}

- (IBAction)rightButtonPressed:(id)sender {
    [self updateScrollingDayBeingViewedNumbers:1];
}


#pragma mark - === Scroll View === -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    const CGFloat x = scrollView.contentOffset.x;
    const CGFloat half = self.scrollViewPageWidth / 2.;

    offsetToLoadPrevious = x - half;
    offsetToLoadNext = x + half;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Switch the indicator when more than 50% of the previous/next page is visible
    BOOL previous;

    if (scrollView.contentOffset.x < offsetToLoadPrevious)
        previous = YES;
    else if (scrollView.contentOffset.x > offsetToLoadNext)
        previous = NO;
    else
        return;

    if (scrollView == self.dayDisplayScrollView)
        [self moveDayDisplayListScrollView:previous moveFromScroll:YES];
    else
        [self moveWeekdayNumbersScrollView:previous moveFromScroll:YES];
}

// This is the one that runs when we scroll the list that has each event for the day.
- (void)moveDayDisplayListScrollView:(BOOL)moveToPrevious moveFromScroll:(BOOL)movedFromScroll {
    CalendarListTableViewController *recycle, *visible;
    CGFloat offset, x;
    
    if (moveToPrevious) {
        recycle = [self.dayViewControllers lastObject];
        [self.dayViewControllers removeLastObject];
        [recycle moveByDays:-3];
        
        visible = [self.dayViewControllers firstObject];
        
        offset = self.scrollViewPageWidth;
        x = 0;
    } else {
        recycle = [self.dayViewControllers firstObject];
        [self.dayViewControllers removeObjectAtIndex:0];
        [recycle moveByDays:3];
        
        visible = [self.dayViewControllers lastObject];
        
        offset = -self.scrollViewPageWidth;
        x = self.scrollViewPageWidth * 2.;
    }
    
    for (CalendarListTableViewController *vc in self.dayViewControllers)
        vc.view.frame = CGRectOffset(vc.view.frame, offset, 0);
    
    CGRect frame = recycle.view.frame;
    frame.origin.x = x;
    recycle.view.frame = frame;
    
    [self.dayDisplayScrollView scrollRectToVisible:visible.view.frame animated:NO];
    
    if (moveToPrevious)
        [self.dayViewControllers insertObject:recycle atIndex:0];
    else
        [self.dayViewControllers addObject:recycle];

    if (movedFromScroll) {
        self.dayBeingViewed = [self.dayViewControllers[1] dayBeingDisplayed];
    } else {
        [self.dayViewControllers[1] setDayBeingDisplayed:self.dayBeingViewed];
        
        NSDateComponents *components = [NSDateComponents new];
        components.day = -1;
        [self.dayViewControllers[0] setDayBeingDisplayed:[self.calendar dateByAddingComponents:components toDate:self.dayBeingViewed options:0]];
        
        components.day = 1;
        [self.dayViewControllers[2] setDayBeingDisplayed:[self.calendar dateByAddingComponents:components toDate:self.dayBeingViewed options:0]];
    }
    
    NSDate *viewing = [self.dayBeingViewed dateWithoutTime];

    if ([viewing compare:self.firstWeekday] == NSOrderedAscending) {
        // We just scrolled to an earlier week, so update that
        [self moveWeekdayNumbersScrollView:YES moveFromScroll:NO];
    } else if ([viewing compare:self.lastWeekday] == NSOrderedDescending) {
        // We just scrolled into the next week
        [self moveWeekdayNumbersScrollView:NO moveFromScroll:NO];
    }
}


// This is the one that runs when we scroll the list of day numbers above the list of events.
- (void)moveWeekdayNumbersScrollView:(BOOL)moveToPrevious moveFromScroll:(BOOL)movedFromScroll {
    CalendarWeekdayRowView *recycle, *visible;
    CGFloat offset, x;
    
    if (moveToPrevious) {
        recycle = [self.dayNumberViews lastObject];
        [self.dayNumberViews removeLastObject];
        [recycle moveByWeeks:-3];
        
        visible = [self.dayNumberViews firstObject];
        
        offset = self.scrollViewPageWidth;
        x = 0;
    } else {
        recycle = [self.dayNumberViews firstObject];
        [self.dayNumberViews removeObjectAtIndex:0];
        [recycle moveByWeeks:3];
        
        visible = [self.dayNumberViews lastObject];
        
        offset = -self.scrollViewPageWidth;
        x = self.scrollViewPageWidth * 2.;
    }
    
    for (CalendarWeekdayRowView *view in self.dayNumberViews)
        view.frame = CGRectOffset(view.frame, offset, 0);
    
    CGRect frame = recycle.frame;
    frame.origin.x = x;
    recycle.frame = frame;
    
    [self.dayNumberScrollView scrollRectToVisible:visible.frame animated:NO];
    
    if (moveToPrevious)
        [self.dayNumberViews insertObject:recycle atIndex:0];
    else
        [self.dayNumberViews addObject:recycle];
    
    if (movedFromScroll) {
        // We swiped the week numbers view
        self.dayBeingViewed = [self.dayNumberViews[1] displayDate];
    } else {
        // We didn't do the swipe, we moved somehow else.
        visible = self.dayNumberViews[1];
        [visible setDisplayDate:self.dayBeingViewed];
    }
    
    self.firstWeekday = [[visible firstWeekday] dateWithoutTime];
    self.lastWeekday = [[visible lastWeekday] dateWithoutTime];
}

@end
