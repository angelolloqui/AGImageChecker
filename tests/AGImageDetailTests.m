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
@synthesize imageDetailVC;
@synthesize imageView;
@synthesize image;
@synthesize viewController;

- (void)setUp {
    [[AGImageChecker sharedInstance] start];    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];    
    image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_small_image" ofType:@"png"]];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleToFill;
    
    //This fails! UILabel init seems to fail in Unit Testing
    viewController = [[UIViewController alloc] init];
    [viewController.view addSubview:imageView];
    imageDetailVC = [AGImageDetailViewController presentModalForImageView:imageView inViewController:viewController];
    [imageDetailVC view];
    
}

- (void)tearDown {
    [[AGImageChecker sharedInstance] stop];
}


- (void)testImageViewIsSetAndHaveIssues {
    STAssertNotNil(imageDetailVC.targetImageView, @"Target ImageView not set");
    STAssertTrue(imageDetailVC.targetImageView.issues != AGImageCheckerIssueNone, @"Target ImageView issues not correctly calculated");
}

- (void)testViewsAndLabelsAreSet {
    STAssertNotNil(imageDetailVC.contentScrollView, @"Scroll view with content not set");
    STAssertNotNil(imageDetailVC.imageViewSizeLabel.text, @"Label with view frame not set");
    STAssertNotNil(imageDetailVC.imageSizeLabel.text, @"Label with image size not set");
    STAssertNotNil(imageDetailVC.contentModeLabel.text, @"Label with content mode not set");
    STAssertNotNil(imageDetailVC.issuesLabel.text, @"Label with issues not set");
    STAssertNotNil(imageDetailVC.imageNameLabel.text, @"Label with image name not set");    
    STAssertNotNil(imageDetailVC.controllerNameLabel.text, @"Label with controller name not set");    
    STAssertNotNil(imageDetailVC.orginalImageView, @"View with  original image not set");    
    STAssertNotNil(imageDetailVC.renderedImageView, @"View with rendered image not set");    
}

@end
