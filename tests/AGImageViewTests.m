//
//  AGImageViewTests.m
//  AGImageChecker
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageViewTests.h"
#import "UIImageView+AGImageChecker.h"

@implementation AGImageViewTests
@synthesize bundle;
@synthesize image;
@synthesize imageView;

- (void) setUp {
    [UIImageView startCheckingImages];
    self.bundle = [NSBundle bundleForClass:[self class]];
    self.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_big_image" ofType:@"png"]];
    self.imageView = [[UIImageView alloc] initWithImage:image];
}

- (void)tearDown {
    [UIImageView stopCheckingImages];
}

- (void)testCheckHandlerCalled {
    __block BOOL called = NO;
    [UIImageView setImageCheckHandler:^(UIImageView *imageView) {
        called = YES;
    }];
    imageView.image = nil;
    STAssertTrue(called, @"The check code should have been called when setting the image");
    
    called = NO;
    imageView.contentMode = UIViewContentModeTop;
    STAssertTrue(called, @"The check code should have been called when setting the contentMode");
    
    called = NO;
    imageView.frame = CGRectZero;
    STAssertTrue(called, @"The check code should have been called when setting the frame");
}

- (void)testIssuesHandlerCalled {
    __block BOOL called = NO;
    [UIImageView setImageIssuesHandler:^(UIImageView *imageView) {
        called = YES;
    }];
    imageView.issues = AGImageCheckerIssueNone;
    STAssertTrue(called, @"The issues handler code should have been called when setting the issues");
}

@end
