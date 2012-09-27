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
#import "AGImageCheckerBasePlugin.h"

@interface AGImageChecker(private)
- (void)tapOnWindow;
@end

@implementation AGImageCheckerTests

@synthesize rootViewController;
@synthesize mockRootView;
@synthesize mockRootViewController;
@synthesize imageChecker;
@synthesize imageView;

static AGImageChecker *originalInstance = nil;

- (void)setUp {
    originalInstance = [AGImageChecker sharedInstance];
    self.imageChecker = [[AGImageChecker alloc] init];
    [AGImageChecker setSharedInstance:imageChecker];
    
    self.rootViewController = [[UIViewController alloc] init];
    [rootViewController setView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)]];
    
    self.mockRootView = [OCMockObject niceMockForClass:[UIView class]];
    self.mockRootViewController = [OCMockObject niceMockForClass:[UIViewController class]];
    [[[mockRootViewController stub] andReturn:mockRootView] view];

    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:rootViewController.view];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [imageChecker setRootViewController:rootViewController];    
}

- (void) tearDown {
    [UIApplication resetApplication];
    [imageChecker stop];
    [AGImageChecker setSharedInstance:originalInstance];
}

- (void)testImageCheckerIsInstanciated {
    STAssertNotNil(imageChecker, @"Can not instanciate the AGImageChecker");
}

- (void)testImageCheckerIsSingleton {
    STAssertEquals(imageChecker, [AGImageChecker sharedInstance], @"Can not instanciate the AGImageChecker");
}

- (void)testImageCheckerCanStartMonitoring {
    STAssertNoThrow([imageChecker start], @"Can not instanciate the AGImageChecker");
    STAssertTrue([imageChecker running], @"AGImageChecker should be running");
}

- (void)testImageCheckerDoNotFailIfMultipleStart {
    [imageChecker start];
    STAssertNoThrow([imageChecker start], @"Can not instanciate the AGImageChecker for a second time");
    STAssertTrue([imageChecker running], @"AGImageChecker should be running");
}

- (void)testImageCheckerCanStopMonitoring {
    STAssertNoThrow([imageChecker stop], @"Can not instanciate the AGImageChecker");
    STAssertFalse([imageChecker running], @"AGImageChecker should not be running");
}

- (void)testImageCheckerCanAssignRootViewController {
    UIViewController *vc = [[UIViewController alloc] init];
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:vc.view];
    STAssertNoThrow([imageChecker setRootViewController:vc], @"Can not set the rootViewController for the AGImageChecker");
    STAssertEquals([imageChecker rootViewController], vc, @"RootViewController not correctly assigned in AGImageChecker");
}

- (void)testImageCheckerAutoAssignRootViewControllerOfTheApp {   
    STAssertNoThrow([imageChecker setRootViewController:nil], @"Can not set the rootViewController for the AGImageChecker");
    UIViewController *vc = [[UIViewController alloc] init];
    id keyWindow = [UIApplication mockWindow];
    [[[keyWindow stub] andReturn:vc] rootViewController];
    [[[(id)[UIApplication sharedApplication] stub] andReturn:keyWindow] keyWindow];
    STAssertEquals([imageChecker rootViewController], vc, @"RootViewController should come from the Window root view controller if none set in AGImageChecker");
}

- (void)testImageCheckerStopsAndStartsWhenChangingRootViewController {
    id mockImageChecker = [OCMockObject partialMockForObject:imageChecker];
    [mockImageChecker setRootViewController:mockRootViewController];
    [(AGImageChecker *)mockImageChecker start];
    UIViewController *vc = [[UIViewController alloc] init];
    
    [[mockImageChecker expect] stop];
    [(AGImageChecker *)[mockImageChecker expect] start];
    [mockImageChecker setRootViewController:vc];
    [mockImageChecker verify];
    [mockImageChecker stop];
}

- (void)testImageCheckerInstantiatesBasePlugin {
    [imageChecker start];
    STAssertTrue([[imageChecker plugins] count] > 0, @"No plugins created by default");
        
    STAssertTrue([[[imageChecker plugins] objectAtIndex:0] isKindOfClass:[AGImageCheckerBasePlugin class]], @"First plugin in the list should be the BasePlugin");
}

- (void)testImageCheckerAllowsAddingAndRemovingPlugins {
    STAssertTrue([[imageChecker plugins] count] == 1, @"Only one plugin expected");
    id<AGImageCheckerPluginProtocol> plugin = [OCMockObject mockForProtocol:@protocol(AGImageCheckerPluginProtocol)];
    [imageChecker addPlugin:plugin];
    [imageChecker addPlugin:plugin];
    STAssertTrue([[imageChecker plugins] count] == 2, @"Two plugins expected");
    [imageChecker removePlugin:plugin];
    STAssertTrue([[imageChecker plugins] count] == 1, @"One plugins expected");
}

- (void)testImageCheckerCallsPluginsForChecking {
    id plugin = [OCMockObject niceMockForProtocol:@protocol(AGImageCheckerPluginProtocol)];
    [imageChecker addPlugin:plugin];
    [imageChecker start];
    AGImageCheckerIssue issues = AGImageCheckerIssueMissing;
    [[plugin expect] calculateIssues:imageView withIssues:issues];
    [imageView layoutSubviews];
    [plugin verify];
}

- (void)testImageCheckerStoreCheckingResult {
    [imageChecker start];
    [imageView layoutSubviews];
    STAssertTrue(imageView.issues != AGImageCheckerIssueNone, @"Issues should be calculated");
}

- (void)testImageCheckerCallsPluginsForDrawing {
    id plugin = [OCMockObject mockForProtocol:@protocol(AGImageCheckerPluginProtocol)];
    [imageChecker addPlugin:plugin];
    [imageChecker start];
    [[plugin expect] didFinishCalculatingIssues:imageView];
    imageView.issues = AGImageCheckerIssueMissing;
    [plugin verify];
}

- (void)testImageCheckerCorrectlySetGesturesInWindow {
    id mockWindow = [UIApplication mockWindow];
    BOOL descendent = YES;
    [[[mockRootView stub] andReturnValue:OCMOCK_VALUE(descendent)] isDescendantOfView:mockWindow];
    [imageChecker setRootViewController:mockRootViewController];
    
    [[mockWindow expect] addGestureRecognizer:imageChecker.tapGesture];
    [imageChecker start];
    [mockWindow verify];
}

- (void)testImageCheckerInteractsWithTheCorrectImage {     
    CGPoint point = CGPointMake(50, 50);
    
    //Mock objects
    id mockGesture = [OCMockObject mockForClass:[UITapGestureRecognizer class]];
    UIGestureRecognizerState state = UIGestureRecognizerStateEnded;
    [[[mockGesture stub] andReturnValue:OCMOCK_VALUE(state)] state];
    [[[mockGesture stub] andReturnValue:[NSValue valueWithCGPoint:point]] locationInView:rootViewController.view];
    [[[mockGesture stub] andReturn:rootViewController.view] view];
    id mockImageChecker = [OCMockObject partialMockForObject:imageChecker];
    [[[mockImageChecker stub] andReturn:mockGesture] tapGesture];
    
    //Create simple view with two levels and with two images on second level (one on top of the other)
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    [view addSubview:imageView];    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 25, 10, 10)];
    [view addSubview:imageView];    
    [self.rootViewController.view addSubview:view];
    
    //Check
    [imageChecker start];
    [[mockImageChecker expect] openImageDetail:imageView];
    [mockImageChecker tapOnWindow];
    [mockImageChecker verify];
}

- (void)testImageCheckerOpensDetailController {    
    id mockController = [OCMockObject partialMockForObject:rootViewController];
    [imageChecker setRootViewController:mockController];
    [imageChecker start];
    [[mockController expect] presentModalViewController:[OCMArg any] animated:YES];
    [imageChecker openImageDetail:imageView];    
    [mockController verify];
}

- (void)testImageCheckerStopsWhenOpeningDetailController {   
    [[AGImageChecker sharedInstance] start];
    [imageChecker removePlugin:[imageChecker.plugins lastObject]];
    [imageChecker openImageDetail:imageView];
    STAssertFalse([imageChecker running], @"ImageChecker should stop when presenting the image details");
    [[AGImageChecker sharedInstance] stop];
}

- (void)testImageCheckerChecksAlreadyLoadedImagesWhenStarted {
    [self.rootViewController.view addSubview:imageView];
    [imageChecker start];
    STAssertTrue(imageView.issues != AGImageCheckerIssueNone, @"Image view loaded should have issue missing at least");
}


@end
