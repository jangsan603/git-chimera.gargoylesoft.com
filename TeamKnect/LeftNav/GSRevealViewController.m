//
//  GSRevealViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/23/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSRevealViewController.h"
#import "UIView+Category.h"

NSString *const GSRevealViewControllerToggleLeftViewController = @"GSRevealViewControllerToggleLeftViewController";
NSString *const GSRevealViewControllerReplaceFrontViewController = @"GSRevealViewControllerReplaceFrontViewController";
NSString *const GSRevealViewControllerReplaceFrontViewControllerKey = @"frontViewController";

#if UGR
@interface GSRevealViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *recognizer;
#else
@interface GSRevealViewController ()
#endif
@property (nonatomic, strong) UIViewController *frontViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) CGFloat frameWidth, frameHeight;
@property (nonatomic, assign) BOOL shouldShowOnEnd;
@property (nonatomic, copy) NSArray *constraints;
@end

@implementation GSRevealViewController

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController leftViewController:(UIViewController *)leftViewController {
    if ((self = [super init])) {
        self.frontViewController = frontViewController;
        self.leftViewController = leftViewController;
        self.leftNavigationPercentage = .8;
        self.slideDuration = .25;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const CGRect frame = self.view.frame;
    self.frameHeight = CGRectGetHeight(frame);
    self.frameWidth = CGRectGetWidth(frame);
    
#if UGR
    [self setupGestureRecognizer];
#endif
    
    // Setup the front view controller containment
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frameWidth, self.frameHeight)];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.containerView];
    
    [self.containerView constrainMeToMatchSuperview:self.view];
    
    
    UIView *view = self.frontViewController.view;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addChildViewController:self.frontViewController];
    [self.containerView addSubview:view];
    
    [self.frontViewController didMoveToParentViewController:self];
    
    self.constraints = [view constrainMeToMatchSuperview:self.containerView];
    
    // And setup the left view controller containment
    [self addChildViewController:self.leftViewController];
    [self.view insertSubview:self.leftViewController.view belowSubview:self.containerView];
    [self.leftViewController didMoveToParentViewController:self];

    [self sizeLeftView];

    __typeof__(self) __weak weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:GSRevealViewControllerToggleLeftViewController object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf toggleLeftDisplay];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:GSRevealViewControllerReplaceFrontViewController object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf replaceFrontViewController:note.userInfo[GSRevealViewControllerReplaceFrontViewControllerKey]];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)replaceFrontViewController:(UIViewController *)newViewController {
    if (self.frontViewController == newViewController) {
        [self hideLeftDisplay];
        return;
    }
    
    UIView *view = newViewController.view;
    
    [self addChildViewController:newViewController];
    
    [self transitionFromViewController:self.frontViewController
                      toViewController:newViewController
                              duration:0
                               options:UIViewAnimationOptionTransitionNone
                            animations:^(void) { }
                            completion:^(BOOL finished) {
                                if (self.constraints)
                                    [self.containerView removeConstraints:self.constraints];
                                
                                [newViewController didMoveToParentViewController:self];
                                
                                [self.frontViewController willMoveToParentViewController:nil];
                                [self.frontViewController removeFromParentViewController];

#if UGR
                                self.recognizer.delegate = nil;
                                [self.frontViewController.view removeGestureRecognizer:self.recognizer];
#endif
                                self.frontViewController = newViewController;
                                
                                self.constraints = [view constrainMeToMatchSuperview:self.containerView];
                                
                                [self hideLeftDisplay];
                                
                                [view setNeedsUpdateConstraints];
                                [view layoutIfNeeded];
                                
#if UGR
                                [self setupGestureRecognizer];
#endif
                            }];
}

- (void)setLeftNavigationPercentage:(CGFloat)leftNavigationPercentage {
    if (leftNavigationPercentage < .05 || leftNavigationPercentage > 1.) {
        NSLog(@"%s: Bad value.  Defaulting to .8", __func__);
        leftNavigationPercentage = .8;
    }
    
    _leftNavigationPercentage = leftNavigationPercentage;
    
    [self sizeLeftView];
}

- (void)sizeLeftView {
    if (![self.leftViewController isViewLoaded])
        return;
    
    self.leftViewController.view.frame = CGRectMake(0, 0, self.frameWidth * self.leftNavigationPercentage, self.frameHeight);
}

#pragma mark - === Show/Hide Left View === -

- (BOOL)leftViewIsHidden {
    return CGRectGetMinX(self.containerView.frame) <= 0;
}

- (void)toggleLeftDisplay {
#if 0
    CALayer *const layer = self.containerView.layer;
    if (self.leftViewIsHidden) {
        // Turn the corner radius on before we start showing.
        layer.shadowOpacity = .8;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOffset = CGSizeMake(-2., -2.);
        layer.cornerRadius = 4.;
    } else {
        layer.shadowOpacity = 0;
        layer.shadowOffset = CGSizeZero;
        layer.cornerRadius = 0;
    }
#endif
    
    [UIView animateWithDuration:self.slideDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect frame = self.containerView.frame;
                         frame.origin.x = self.leftViewIsHidden ? self.frameWidth * self.leftNavigationPercentage : 0;
                         self.containerView.frame = frame;
                     } completion:NULL];
}

- (void)showLeftDisplay {
    if (!self.leftViewIsHidden)
        return;
    
    [self toggleLeftDisplay];
}

- (void)hideLeftDisplay {
    if (self.leftViewIsHidden)
        return;
    
    [self toggleLeftDisplay];
}

#pragma mark - === Gesture Recognizers === -

#if UGR
- (void)setupGestureRecognizer {
    self.recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swiped)];
    self.recognizer.maximumNumberOfTouches = 1;
    self.recognizer.delegate = self;
    
    [self.frontViewController.view addGestureRecognizer:self.recognizer];
}

- (void)swiped {
    static BOOL honor;
    
    UIView *const view = self.recognizer.view;
    
    [view.layer removeAllAnimations];
    
    const CGPoint point = [self.recognizer translationInView:self.view];
    const CGPoint velocity = [self.recognizer velocityInView:view];
    
    const UIGestureRecognizerState state = self.recognizer.state;
    if (state == UIGestureRecognizerStateBegan) {
        honor = (velocity.x > 0 && [self leftViewIsHidden]) || (velocity.x < 0 && ![self leftViewIsHidden]);
    } else if (state == UIGestureRecognizerStateChanged) {
        if (!honor)
            return;
        
        view.frame = CGRectOffset(view.frame, point.x, 0);
        [self.recognizer setTranslation:CGPointZero inView:self.view];
    } else if (state == UIGestureRecognizerStateEnded) {
        if (!honor)
            return;
        
    }
}
#endif

@end
