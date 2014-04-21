//
//  UITests.m
//  UITests
//
//  Created by Scott Grosch on 2/21/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import "UIView+FindViewController.h"

@interface UITests : KIFTestCase

@end

@implementation UITests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    [tester waitForViewWithAccessibilityLabel:@"Left Navigation"];
    [tester tapViewWithAccessibilityLabel:@"Musketeers"];
}

@end
