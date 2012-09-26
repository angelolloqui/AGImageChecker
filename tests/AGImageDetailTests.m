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
@synthesize imageDetailVC;
@synthesize initialPlugins;

- (void)setUp {
    //Remove all plugins
    NSArray *plugins = [[[AGImageChecker sharedInstance] plugins] copy];
    for (id plugin in plugins){
        [[AGImageChecker sharedInstance] removePlugin:plugin];
    }
    
    [[AGImageChecker sharedInstance] start];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];    
    image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_small_image" ofType:@"png"]];
    imageView = [[UIImageView alloc] initWithImage:image];
    viewController = [[UIViewController alloc] init];
    [viewController.view addSubview:imageView];
    
    imageDetailVC = [AGImageDetailViewController presentModalForImageView:imageView inViewController:viewController];
}

- (void)tearDown {
    [[AGImageChecker sharedInstance] stop];
    //Init again to recover plugins
    [AGImageChecker setSharedInstance:[[AGImageChecker alloc] init]];
}

- (void)testImageViewIsSetAndHaveIssues {
    [imageDetailVC view];
    STAssertEqualObjects(imageDetailVC.targetImageView, imageView, @"Target ImageView not correctly set");
    STAssertNotNil(imageDetailVC.contentScrollView, @"Scroll view with content not set");
}

- (void)testControllerCallsPluginsForPresentingDetails {
    id plugin = [OCMockObject niceMockForProtocol:@protocol(AGImageCheckerPluginProtocol)];
    __block BOOL called = NO;
    [[[plugin stub] andDo:^(NSInvocation *inv) {
        called = YES;
    }] detailForViewController:imageDetailVC withImageView:imageView withIssues:AGImageCheckerIssueNone];
    
    [[AGImageChecker sharedInstance] addPlugin:plugin];
    [imageDetailVC viewDidLoad];
    STAssertTrue(called, @"The plugin code for detail page was not called");    
}


- (void)testControllerCallsPluginsWhenRefreshingDetails {
    [imageDetailVC view];
    STAssertNotNil(imageDetailVC.view, @"The view should be already set");
    
    id plugin = [OCMockObject niceMockForProtocol:@protocol(AGImageCheckerPluginProtocol)];
    __block BOOL called = NO;
    [[[plugin stub] andDo:^(NSInvocation *inv) {
        called = YES;
    }] detailForViewController:imageDetailVC withImageView:imageView withIssues:AGImageCheckerIssueNone];
    
    [[AGImageChecker sharedInstance] addPlugin:plugin];
    [imageDetailVC refreshContentView];
    STAssertTrue(called, @"The plugin code for detail page was not called");
}





@end
