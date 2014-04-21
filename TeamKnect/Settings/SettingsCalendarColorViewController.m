//
//  SettingsCalendarColorViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 3/10/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//


#import "SettingsCalendarColorViewController.h"
#import "ISColorWheel.h"

@interface SettingsCalendarColorViewController () <ISColorWheelDelegate>
@property (weak, nonatomic) IBOutlet ISColorWheel *colorWheel;
@property (weak, nonatomic) IBOutlet UIView *colorDisplay;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@end

@implementation SettingsCalendarColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.colorWheel.delegate = self;
    self.colorWheel.continuous = YES;
    self.colorWheel.brightness = 1.;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.colorWheel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.colorWheel
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1 constant:0]];
    
    self.colorDisplay.layer.borderColor = [UIColor blackColor].CGColor;
    self.colorDisplay.layer.borderWidth = 1.;
    
    self.slider.value = 1.;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.colorWheel updateImage];
    self.colorDisplay.backgroundColor = self.initialColor;
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.colorWheel.brightness = sender.value;
    [self.colorWheel updateImage];
    self.colorDisplay.backgroundColor = self.colorWheel.currentColor;
}

- (void)colorWheelDidChangeColor:(ISColorWheel *)colorWheel {
    self.colorDisplay.backgroundColor = self.colorWheel.currentColor;
}

- (UIColor *)selectedColor {
    return self.colorWheel.currentColor;
}

@end
