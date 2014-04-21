//
//  AccessoryViewToolbar.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/5/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "AccessoryViewToolbar.h"

@interface AccessoryViewToolbar () {
    NSUInteger maxIndex;
}
@property (nonatomic, copy) NSArray *order;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, copy) AccessoryViewToolbarBlock onBecomeFirstResponder;
@end

@implementation AccessoryViewToolbar

- (instancetype)initAccessoryView:(CGFloat)screenWidth textFields:(const NSArray *const)fields inScrollView:(UIScrollView *)scrollView onBecomeFirstResponder:(AccessoryViewToolbarBlock)onBecomeFirstResponder {
    
    if ((self = [super initWithFrame:CGRectMake(0, 0, screenWidth, 50.)])) {
        self.onBecomeFirstResponder = onBecomeFirstResponder;

        self.scrollView = scrollView;
        
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[
                                                                                  NSLocalizedString(@"ACCESSORY_VIEW_PREV_BUTTON", @"The 'prev' button that goes to the previous UITextField."),
                                                                                  NSLocalizedString(@"ACCESSORY_VIEW_NEXT_BUTTON", @"The 'next' button that goes to the next UITextField.")
                                                                                  ]];
        segment.momentary = YES;

        [segment addTarget:self action:@selector(segmentTouched:) forControlEvents:UIControlEventValueChanged];

        UIBarButtonItem *seg = [[UIBarButtonItem alloc] initWithCustomView:segment];

        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil action:nil];
        UIBarButtonItem *dismiss = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TOOLBAR_DISMISS", @"Text on the toolbar which will dismiss the keyboard.")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(dismissButtonPressed)];

        self.items = @[seg, space, dismiss];

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        self.order = (NSArray *) fields;
        maxIndex = [fields count] - 1;

        // Could be UITextField or UITextView
        for (id view in fields) {
            if ([view conformsToProtocol:@protocol(UITextInputTraits)]) {
                id<UITextInputTraits> field = view;
                field.enablesReturnKeyAutomatically = YES;
                field.returnKeyType = UIReturnKeyNext;
            }

            if ([view respondsToSelector:@selector(setInputAccessoryView:)])
                [view performSelector:@selector(setInputAccessoryView:) withObject:self];
        }

        id last = [fields lastObject];
        if ([last conformsToProtocol:@protocol(UITextInputTraits)]) {
            id<UITextInputTraits> field = last;
            field.returnKeyType = UIReturnKeyDone;
        }
    }

    return self;
}

- (instancetype)initAccessoryView:(CGFloat)screenWidth textFields:(const NSArray *const)fields inScrollView:(UIScrollView *)scrollView {
    return [self initAccessoryView:screenWidth textFields:fields inScrollView:scrollView onBecomeFirstResponder:nil];
}

- (void)makeFieldFirstResponder:(UIView *)view {
    [view becomeFirstResponder];
    if (self.onBecomeFirstResponder)
        self.onBecomeFirstResponder(view);
    
    [self.scrollView scrollRectToVisible:view.frame animated:YES];
}

- (void)move:(NSEnumerator *)enumerator {
    UITextField *field;

    while (field = [enumerator nextObject])
        if ([field isFirstResponder]) {
            if (field = [enumerator nextObject])
                [self makeFieldFirstResponder:field];

            return;
        }
}

- (void)segmentTouched:(UISegmentedControl *)segment {
    NSEnumerator *enumerator = (segment.selectedSegmentIndex == 0) ? [self.order reverseObjectEnumerator] : [self.order objectEnumerator];
    [self move:enumerator];
}

- (void)dismissButtonPressed {
    for (UITextField *field in self.order)
        if ([field isFirstResponder]) {
            [field resignFirstResponder];
            return;
        }
}

- (void)moveToNextFieldAfter:(const UITextField *)field {
    NSUInteger idx = [self.order indexOfObject:field] + 1;
    if (idx <= maxIndex)
        [self makeFieldFirstResponder:self.order[idx]];
}

@end
