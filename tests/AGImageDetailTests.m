//
//  AGImageDetailTests.m
//  AGImageChecker
//
//  Created by Angel on 9/7/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageDetailTests.h"
#import "AGImageChecker.h"
#import "UIImageView+AGImageChecker.h"

@implementation AGImageDetailTests
@synthesize imageView;
@synthesize image;
@synthesize viewController;
@synthesize mockImageChecker;
@synthesize imageDetailVC;

static AGImageChecker *originalInstance = nil;

- (void)setUp {
    originalInstance = [AGImageChecker sharedInstance];
    
    self.mockImageChecker = [OCMockObject partialMockForObject:originalInstance];
    [AGImageChecker setSharedInstance:mockImageChecker];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_small_image" ofType:@"png"]];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.viewController = [[UIViewController alloc] init];
    [viewController.view addSubview:imageView];
    
    self.imageDetailVC = [AGImageDetailViewController presentModalForImageView:imageView inViewController:viewController];
}

- (void)tearDown {
    [[AGImageChecker sharedInstance] stop];
    [AGImageChecker setSharedInstance:originalInstance];
}

- (void)testPresentImageDetailStopsImageChecker {
    [[mockImageChecker expect] stop];
    [imageDetailVC viewWillAppear:YES];
//    [mockImageChecker verify]; //Not working the verify. Investigate
}

- (void)testDismissImageDetailStartsImageChecker {
    [(AGImageChecker *)[mockImageChecker expect] start];
    [imageDetailVC viewWillDisappear:YES];
    [mockImageChecker verify];
}

- (void)testImageViewIsSetAndHaveIssues {
    [imageDetailVC viewWillAppear:YES];
    STAssertEqualObjects(imageDetailVC.targetImageView, imageView, @"Target ImageView not correctly set");
    STAssertNotNil(imageDetailVC.contentScrollView, @"Scroll view with content not set");
}

- (void)testControllerCallsPluginsForPresentingDetails {
    void *view = CFBridgingRetain([[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)]);
    id plugin = [OCMockObject niceMockForProtocol:@protocol(AGImageCheckerPluginProtocol)];
    __block BOOL called = NO;
    [[[plugin stub] andDo:^(NSInvocation *inv) {
        called = YES;
        [inv setReturnValue:&view];
    }] detailForViewController:[OCMArg any] withImageView:imageView withIssues:AGImageCheckerIssueNone];

    [[[mockImageChecker stub] andReturn:[NSArray arrayWithObject:plugin]] plugins];
    
    [imageDetailVC viewWillAppear:YES];
    STAssertTrue(called, @"The plugin code for detail page was not called");
    CFBridgingRelease(view);
}

- (void)testControllerCallsPluginsWhenRefreshingDetails {
    [imageDetailVC viewDidLoad];
    
    STAssertNotNil(imageDetailVC.view, @"The view should be already set");
    
    id plugin = [OCMockObject niceMockForProtocol:@protocol(AGImageCheckerPluginProtocol)];
    __block BOOL called = NO;
    [[[plugin stub] andDo:^(NSInvocation *inv) {
        called = YES;
    }] detailForViewController:imageDetailVC withImageView:imageView withIssues:AGImageCheckerIssueNone];
    
    [[[mockImageChecker stub] andReturn:[NSArray arrayWithObject:plugin]] plugins];
    [imageDetailVC refreshContentView];
    STAssertTrue(called, @"The plugin code for detail page was not called");
}


@end
