//
//  CalendarMonthViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/14/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "CalendarMonthViewController.h"
#import "CalendarListTableViewController.h"
#import "NSCalendar+LocalizedNames.h"
#import "CalendarMonthViewHeader.h"
#import "NSDate+DateWithoutTime.h"
#import "CalendarMonthViewCell.h"
#import <EventKit/EventKit.h>
#import "UIView+Category.h"
#import "AppDelegate.h"
#import "Team.h"

@interface CalendarMonthViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *monthCollectionView;
@property (weak, nonatomic) IBOutlet UIView *appointmentsListView;
@property (weak, nonatomic) IBOutlet UIView *dividerLine;
@property (nonatomic, strong) CalendarListTableViewController *appointmentsListViewController;
@property (nonatomic, strong) NSMutableDictionary *datesWithEvents;
@property (nonatomic, weak) CalendarMonthViewHeader *headerView;
@property (nonatomic, assign) CGSize collectionViewCellSize;
@property (nonatomic, assign) NSInteger blankDaysCount;
@property (nonatomic, strong) NSMutableArray *dates;
@property (nonatomic, copy) NSArray *weekdaySymbols;
@property (nonatomic, assign) NSInteger startColumn;
@property (nonatomic, assign) NSInteger daysPerWeek;
@property (nonatomic, assign) NSInteger daysInMonth;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *buildDate;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, strong) NSDateFormatter *headerDateFormatter;
@property (nonatomic, copy) NSArray *startDays, *endDays;
@end

@implementation CalendarMonthViewController

- (void)viewDidLoad
{
//    NSLog(@"%s loading", __func__);
    [super viewDidLoad];
    
    __typeof__(self) __weak weakSelf = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalendar:) name:NSCurrentLocaleDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalendar:) name:EKEventStoreChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:kJumpToSpecificDayNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        __typeof__(self) __strong strongSelf = weakSelf;

        strongSelf.dates = nil;
        strongSelf.buildDate = [note.userInfo[kJumpToSpecificDayValue] dateWithoutTime];
        strongSelf.selectedDate = self.buildDate;
        [strongSelf buildCalendar];
        strongSelf.headerView.date.text = [NSDateFormatter localizedStringFromDate:strongSelf.selectedDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    }];
    
    self.dividerLine.backgroundColor = kTintColor;
    
    self.calendar = [NSCalendar autoupdatingCurrentCalendar];

    self.daysPerWeek = [self.calendar maximumRangeOfUnit:NSCalendarUnitWeekday].length;
    const CGFloat size = CGRectGetWidth(self.monthCollectionView.frame) / (CGFloat) self.daysPerWeek;
    
    self.collectionViewCellSize = CGSizeMake(size, 44.);
    
    self.monthCollectionView.bounces = NO;
    self.monthCollectionView.scrollEnabled = NO;
    self.monthCollectionView.delegate = self;
    self.monthCollectionView.dataSource = self;
    self.monthCollectionView.backgroundColor = [UIColor whiteColor];
    self.monthCollectionView.allowsMultipleSelection = NO;

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.monthCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 1;

    CGSize headerSize = layout.headerReferenceSize;
    headerSize.height = 54.;
    layout.headerReferenceSize = headerSize;

    self.appointmentsListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"calendarListTableView"];
    self.appointmentsListViewController.managedObjectContext = self.managedObjectContext;
    self.appointmentsListViewController.calendar = self.calendar;
    self.appointmentsListViewController.team = self.team;

    // This must be set after team is set as the property setting for dayBeingDisplayed uses the value of team.
    self.appointmentsListViewController.dayBeingDisplayed = [NSDate date];
    
    UIView *alvc = self.appointmentsListViewController.view;

    [self addChildViewController:self.appointmentsListViewController];
    [self.appointmentsListView addSubview:alvc];
    [self.appointmentsListViewController didMoveToParentViewController:self];

    [alvc constrainMeToMatchSuperview:self.appointmentsListView];

    self.selectedDate = [[NSDate date] dateWithoutTime];
    self.buildDate = self.selectedDate;

    [self.appointmentsListViewController setDayBeingDisplayed:self.selectedDate];

    [self buildCalendar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadCalendar:(NSNotification *)note {
    [self buildCalendar];
    [self.appointmentsListViewController moveByDays:0];
}

- (void)buildCalendar {
    self.weekdaySymbols = [self.calendar currentLocaleShortWeekdaySymbols];
    [self buildMonthBasedOnDate:self.dates ? self.dates[0] : self.buildDate];

    if (self.team)
        [self loadCalendarForTeam];
    else
        [self loadAllTeamCalendars];

    [self.monthCollectionView reloadData];
}

- (void)buildMonthBasedOnDate:(NSDate *)date {
    date = [[self.calendar firstSecondOfFirstDayOfMonthContaining:date] dateWithoutTime];
    NSDateComponents *firstDayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:date];

    self.daysInMonth = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;

    self.dates = [[NSMutableArray alloc] initWithCapacity:self.daysInMonth];

    NSDateComponents *components = [NSDateComponents new];
    components.day = 1;

    for (NSInteger i = self.daysInMonth - 1; i >= 0; i--) {
        [self.dates addObject:date];
        date = [self.calendar dateByAddingComponents:components toDate:date options:0];
    }

    self.blankDaysCount = firstDayComponents.weekday - 1 + (1 - self.calendar.firstWeekday);

    NSDateComponents *yesterday = [NSDateComponents new];
    yesterday.day = -1;
    
    NSDate *const lastDayOfLastMonth = [self.calendar dateByAddingComponents:yesterday toDate:[self.dates firstObject] options:0];
    const NSRange days = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:lastDayOfLastMonth];
    
    NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:self.blankDaysCount];
    for (NSInteger i = self.blankDaysCount - 1; i >= 0; i--)
        [ary addObject:@(days.length - i)];
    
    self.startDays = ary;
    
    NSInteger leftover = self.daysPerWeek - ((self.daysInMonth + self.blankDaysCount) % self.daysPerWeek);
    if (leftover) {
        leftover++;
        ary = [[NSMutableArray alloc] initWithCapacity:leftover];
        for (int i = 1; i < leftover; i++)
            [ary addObject:@(i)];
        self.endDays = ary;
    } else {
        self.endDays = nil;
    }
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.monthCollectionView.collectionViewLayout;
    const CGFloat numberOfRows = ceil((self.daysInMonth + self.blankDaysCount) / (CGFloat)self.daysPerWeek);
    const CGFloat necessaryHeight = numberOfRows * (self.collectionViewCellSize.height + layout.minimumLineSpacing) + layout.headerReferenceSize.height;
    
    self.collectionViewHeightConstraint.constant = necessaryHeight;
}

#pragma mark - === Collection View === -

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CalendarMonthViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"normal" forIndexPath:indexPath];

    if (indexPath.row < self.blankDaysCount) {
        [cell setDayNumber:[self.startDays[indexPath.row] integerValue] dotColor:[UIColor clearColor] textColor:[UIColor grayColor]];
        cell.dayIsSelected = NO;
        return cell;
    }
    
    NSInteger firstIndexOfNextMonth = self.daysInMonth + self.blankDaysCount;
    if (indexPath.row >= firstIndexOfNextMonth) {
        [cell setDayNumber:[self.endDays[indexPath.row - firstIndexOfNextMonth] integerValue] dotColor:[UIColor clearColor] textColor:[UIColor grayColor]];
        cell.dayIsSelected = NO;
        return cell;
    }
    
    NSInteger index = indexPath.row - self.blankDaysCount;
    [cell setDayNumber:index + 1 dotColor:[self.datesWithEvents[@(index)] boolValue] ? self.dotColor : [UIColor clearColor] textColor:kTintColor];
    cell.dayIsSelected = [self.selectedDate compare:self.dates[index]] == NSOrderedSame;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedDate = self.dates[indexPath.row - self.blankDaysCount];

    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedDateChangedNotification object:self.selectedDate];
    
    // TODO: Could really optimize this to just load the old and new selection date.
    [collectionView reloadData];

    self.headerView.date.text = [NSDateFormatter localizedStringFromDate:self.selectedDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];

    [self.appointmentsListViewController setDayBeingDisplayed:self.selectedDate];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // These are the insets around the collection view as a whole, not the cells or rows.
    return UIEdgeInsetsMake(0, 0, 7, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionViewCellSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.daysInMonth + self.blankDaysCount + self.endDays.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row >= self.blankDaysCount && indexPath.row < self.blankDaysCount + self.daysInMonth;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (self.headerView)
        return self.headerView;
    
    self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"normal" forIndexPath:indexPath];
    
    __typeof__(self) __weak weakSelf = self;
    self.headerView.onMonthChangePressed = ^(BOOL left) {
        [weakSelf moveMonthBy:left ? -1 : 1];
    };
    
    self.headerView.date.text = [NSDateFormatter localizedStringFromDate:self.selectedDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];

    // TODO: Get this shit into the class.
    const CGFloat width = self.collectionViewCellSize.width;

    CGFloat x = 0;

    NSLocale *locale = [NSLocale currentLocale];
    
    NSInteger tag = 1;
    for (NSString *const name in self.weekdaySymbols) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 31., width, 17.)];
        label.tag = tag;
        label.textColor = kTintColor;
        label.font = [UIFont boldSystemFontOfSize:12.];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [name uppercaseStringWithLocale:locale];
        
        [self.headerView addSubview:label];

        x += width;
        tag++;
    }

    return self.headerView;
}

#pragma mark - === Calendar === -

- (void)loadAllTeamCalendars {
    NSArray *calendars = [[CalendarEventStore sharedInstance] allocTeamCalendarsInManagedObjectContext:self.managedObjectContext];
    if (calendars.count == 0)
        return;

    [self loadCalendars:calendars];
}

- (void)loadCalendarForTeam {
    EKCalendar *cal = [[CalendarEventStore sharedInstance] calendarWithIdentifier:self.team.calendarIdentifier];
    if (!cal)
        return;
    
    [self loadCalendars:@[cal]];
}

- (void)loadCalendars:(NSArray *)calendars {
    EKCalendar *calendar = [calendars firstObject];
    self.dotColor = [UIColor colorWithCGColor:calendar.CGColor];

    NSDate *const start = [self.calendar firstSecondOfFirstDayOfMonthContaining:self.dates[0]];
    NSDate *const end = [self.calendar lastSecondOfLastDayOfMonthContaining:self.dates[0]];

    NSPredicate *predicate;
    @try {
        predicate = [[CalendarEventStore sharedInstance] predicateForEventsWithStartDate:start endDate:end calendars:calendars];
    } @catch (NSException *ex) {
        NSLog(@"EXCEPTION for '%@' to '%@': %@", [start dateAndTime], [end dateAndTime], ex);
        abort();
    }

    self.datesWithEvents = [NSMutableDictionary new];

    for (const EKEvent *event in [[CalendarEventStore sharedInstance] eventsMatchingPredicate:predicate]) {
        const NSDateComponents *const components = [self.calendar components:NSCalendarUnitDay fromDate:event.startDate];

        // We're going to use this as an index, so go to 0-based
        NSInteger startDay = components.day - 1;

        NSDate *fromDate, *toDate;
        [self.calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:0 forDate:event.startDate];
        [self.calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:0 forDate:event.endDate];

        NSInteger difference = labs([self.calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0].day) + 1;
        for (NSInteger i = 0; i < difference; i++) {
            NSNumber *key = @(startDay + i);
            self.datesWithEvents[key] = @YES;
        }
    }
}

- (NSDateFormatter *)headerDateFormatter {
    if (_headerDateFormatter != nil)
        return _headerDateFormatter;
    
    self.headerDateFormatter = [[NSDateFormatter alloc] init];
    _headerDateFormatter.dateFormat = @"MMMM YYYY";
    
    return _headerDateFormatter;
}

- (void)moveMonthBy:(NSInteger)months {
    NSDateComponents *components = [NSDateComponents new];
    components.month = months;

    self.buildDate = [self.calendar dateByAddingComponents:components toDate:self.buildDate options:0];
    
    self.selectedDate = [self.calendar dateByAddingComponents:components toDate:self.selectedDate options:0];
    [self.appointmentsListViewController setDayBeingDisplayed:self.selectedDate];
    
    self.dates = nil;
    [self buildCalendar];
    
    self.headerView.date.text = [self.headerDateFormatter stringFromDate:self.buildDate];
}

@end
