//
//  AccessoryViewToolbar.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/5/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

@interface AccessoryViewToolbar : UIToolbar

typedef void (^AccessoryViewToolbarBlock)(UIView *view);

/**
  * Adds a view above the keyboard with a prev/next @c UISegmentControl and a Dismiss button.
  * @param screenWidth Pass in @c CGRectGetWidth(self.view.bounds) for this parameter.
  * @param fields An ordered array of @c UITextField and/or @c UITextView elements that should be controlled by the next/prev @c UISegmentControl.
  * @param scrollView The @c UIScrollView that the fields are contained in.  The scroll view is @b NOT retained.
  * @param onBecomeFirstResponder A block which will be called with the field which became the first responder.
  */
- (instancetype)initAccessoryView:(CGFloat)screenWidth textFields:(const NSArray *const)fields inScrollView:(UIScrollView *)scrollView onBecomeFirstResponder:(AccessoryViewToolbarBlock)onBecomeFirstResponder;

/**
 * Adds a view above the keyboard with a prev/next @c UISegmentControl and a Dismiss button.
 * @param screenWidth Pass in @c CGRectGetWidth(self.view.bounds) for this parameter.
 * @param fields An ordered array of @c UITextField and/or @c UITextView elements that should be controlled by the next/prev @c UISegmentControl buttons.
 * @param scrollView The @c UIScrollView that the fields are contained in.  The scroll view is @b NOT retained.
 */
- (instancetype)initAccessoryView:(CGFloat)screenWidth textFields:(const NSArray *const)fields inScrollView:(UIScrollView *)scrollView;

/**
  * Moves to the indicated field and updates the state of the next/prev buttons.
  * @param field The @c UITextField to move to.
  */
- (void)moveToNextFieldAfter:(const UITextField *)field;

@end
