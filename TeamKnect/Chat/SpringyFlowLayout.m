//
//  SpringyFlowLayout.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/29/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

// Code copied from the WWDC 2013 session 217 - Exploring Scroll Views on iOS 7

#import "SpringyFlowLayout.h"

@interface SpringyFlowLayout ()
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@end

@implementation SpringyFlowLayout

- (void)prepareLayout {
    [super prepareLayout];

    if (self.dynamicAnimator)
        return;

    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];

    const CGSize contentSize = [self collectionViewContentSize];
    NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];

    for (UICollectionViewLayoutAttributes *item in items) {
        UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];

        // If spring length was greater than 0, it wouldn't come to rest at its anchor point.
        spring.length = 0;
        spring.damping = .5;
        spring.frequency = .8;

        // Could do tiling to just add behaviors that are near what's available on the screen at any given time.
        [self.dynamicAnimator addBehavior:spring];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    UICollectionView *const cv = self.collectionView;
    const CGFloat scrollDelta = CGRectGetMinY(newBounds) - CGRectGetMinY(cv.bounds);
    const CGPoint touchLocation = [cv.panGestureRecognizer locationInView:cv];

    for (UIAttachmentBehavior *spring in self.dynamicAnimator.behaviors) {
        const CGPoint anchorPoint = spring.anchorPoint;
        const CGFloat distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
        const CGFloat scrollResistance = distanceFromTouch / 500.;

        UICollectionViewLayoutAttributes *item = [spring.items firstObject];

        CGPoint center = item.center;
        center.y += MIN(scrollDelta, scrollDelta * scrollResistance);
        item.center = center;

        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }

    // The dynamics will invalidate the layout
    return NO;
}

@end
