//
//  AGImageCheckerTests.m
//  AGImageChecker
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageCheckerTests.h"
#import "AGImageChecker.h"
#import "UIImageView+AGImageChecker.h"

@interface AGImageChecker(private)
- (void)tapOnWindow;
@end

@implementation AGImageCheckerTests

@synthesize rootViewController;
@synthesize mockRootView;
@synthesize mockRootViewController;

- (void)setUp {
    rootViewController = [[UIViewController alloc] init];    
    [rootViewController setView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)]];
    
    mockRootView = [OCMockObject niceMockForClass:[UIView class]];
    mockRootViewController = [OCMockObject niceMockForClass:[UIViewController class]];
    [[[mockRootViewController stub] andReturn:mockRootView] view];
    
    [[AGImageChecker sharedInstance] setRootViewController:rootViewController];
}

- (void) tearDown {
    [UIApplication resetApplication];
    [[AGImageChecker sharedInstance] stop];
}

- (void)testImageCheckerIsInstanciated {
    STAssertNotNil([AGImageChecker sharedInstance], @"Can not instanciate the AGImageChecker");
}

- (void)testImageCheckerIsSingleton {
    STAssertEquals([AGImageChecker sharedInstance], [AGImageChecker sharedInstance], @"Can not instanciate the AGImageChecker");
}

- (void)testImageCheckerCanStartMonitoring {
    STAssertNoThrow([[AGImageChecker sharedInstance] start], @"Can not instanciate the AGImageChecker");
    STAssertTrue([[AGImageChecker sharedInstance] running], @"AGImageChecker should be running");
}

- (void)testImageCheckerDoNotFailIfMultipleStart {
    [[AGImageChecker sharedInstance] start];
    STAssertNoThrow([[AGImageChecker sharedInstance] start], @"Can not instanciate the AGImageChecker for a second time");
    STAssertTrue([[AGImageChecker sharedInstance] running], @"AGImageChecker should be running");
}

- (void)testImageCheckerCanStopMonitoring {
    STAssertNoThrow([[AGImageChecker sharedInstance] stop], @"Can not instanciate the AGImageChecker");
    STAssertFalse([[AGImageChecker sharedInstance] running], @"AGImageChecker should not be running");
}

- (void)testImageCheckerCanAssignRootViewController {
    UIViewController *vc = [[UIViewController alloc] init];
    STAssertNoThrow([[AGImageChecker sharedInstance] setRootViewController:vc], @"Can not set the rootViewController for the AGImageChecker");
    STAssertEquals([[AGImageChecker sharedInstance] rootViewController], vc, @"RootViewController not correctly assigned in AGImageChecker");
}

- (void)testImageCheckerAutoAssignRootViewControllerOfTheApp {   
    STAssertNoThrow([[AGImageChecker sharedInstance] setRootViewController:nil], @"Can not set the rootViewController for the AGImageChecker");
    UIViewController *vc = [[UIViewController alloc] init];
    id keyWindow = [[UIApplication sharedApplication] keyWindow];
    [[[keyWindow stub] andReturn:vc] rootViewController];
    STAssertEquals([[AGImageChecker sharedInstance] rootViewController], vc, @"RootViewController should come from the Window root view controller if none set in AGImageChecker");
}

- (void)testImageCheckerCorrectlySetGesturesInWindow {    
    [[AGImageChecker sharedInstance] setRootViewController:mockRootViewController];
    [[mockRootView expect] addGestureRecognizer:[AGImageChecker sharedInstance].tapGesture];
    [[AGImageChecker sharedInstance] start];
    [mockRootView verify];
    
    [[mockRootView expect] removeGestureRecognizer:[AGImageChecker sharedInstance].tapGesture];
    [[AGImageChecker sharedInstance] stop];    
    [mockRootView verify];    
}

- (void)testImageCheckerInteractsWithTheCorrectImage {     
    CGPoint point = CGPointMake(50, 50);
    
    //Mock objects
    id mockGesture = [OCMockObject mockForClass:[UITapGestureRecognizer class]];
    [[[mockGesture stub] andReturnValue:[NSValue valueWithCGPoint:point]] locationInView:rootViewController.view];
    id mockImageChecker = [OCMockObject partialMockForObject:[AGImageChecker sharedInstance]];
    [[[mockImageChecker stub] andReturn:mockGesture] tapGesture];
    
    //Create simple view with two levels and with two images on second level (one on top of the other)
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [view addSubview:imageView];    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 25, 10, 10)];
    [view addSubview:imageView];    
    [self.rootViewController.view addSubview:view];
    
    //Check
    [[AGImageChecker sharedInstance] start];
    [[mockImageChecker expect] openImageDetail:imageView];
    [mockImageChecker tapOnWindow];
    [mockImageChecker verify];
}

- (void)testImageCheckerOpensDetailController {    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    id mockController = [OCMockObject partialMockForObject:rootViewController];
    [[AGImageChecker sharedInstance] setRootViewController:mockController];
    [[AGImageChecker sharedInstance] start];
    [[mockController expect] presentModalViewController:[OCMArg any] animated:YES];
    [[AGImageChecker sharedInstance] openImageDetail:imageView];    
    [mockController verify];
}

- (void)testImageCheckerChecksAlreadyLoadedImagesWhenStarted {     
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.rootViewController.view addSubview:imageView];
    STAssertTrue(imageView.issues == AGImageCheckerIssueNone, @"Image view should not have issues before starting");
    [[AGImageChecker sharedInstance] start];
    STAssertTrue(imageView.issues != AGImageCheckerIssueNone, @"Image view loaded should have issue missing at least");
}


@end
