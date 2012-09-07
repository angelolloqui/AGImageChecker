//
//  AGImageChecker.m
//  Ziggo TV
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "AGImageChecker.h"
#import "UIImageView+AGImageChecker.h"
#import <QuartzCore/QuartzCore.h>

@implementation AGImageChecker

#pragma mark Life cycle

static AGImageChecker *sharedInstance = nil;
+ (AGImageChecker *)sharedInstance
{
#ifdef DEBUG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
#endif
	return sharedInstance;
}

static UITapGestureRecognizer *windowGesture = nil;
- (id)init {
    self = [super init];
    if (self) {
        windowGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnWindow)];
        windowGesture.numberOfTapsRequired = 2;
    }
    return self;
}

#pragma mark Public API

- (void)start {
    [UIImageView startCheckingImages];
    [UIImageView setImageIssuesHandler:^(UIImageView *imageView, AGImageCheckerIssue issues) {
        [[AGImageChecker sharedInstance] drawIssues:issues forImageView:imageView];
    }];
    [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:windowGesture];
}

- (void)stop {
    [UIImageView stopCheckingImages];
    [UIImageView setImageIssuesHandler:nil];
    [[[UIApplication sharedApplication] keyWindow] removeGestureRecognizer:windowGesture];
}


#pragma mark Drawing

- (void)drawIssues:(AGImageCheckerIssue)issues forImageView:(UIImageView *)imageView  {
    
    imageView.layer.borderWidth = 0;
    imageView.layer.borderColor = nil;
    
    if (!imageView.hidden && imageView.alpha > 0) {
        //    if (issues & AGImageCheckerIssueResized) {
        //        imageView.layer.borderWidth = 2;
        //        imageView.layer.borderColor = [UIColor yellowColor].CGColor;
        //    }
        
        if (issues & AGImageCheckerIssueBlurry) {
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = [UIColor yellowColor].CGColor;
        }
        
        if (issues & AGImageCheckerIssueStretched) {
            imageView.layer.borderWidth = 2;
            imageView.layer.borderColor = [UIColor orangeColor].CGColor;
        }    
        
        if (issues & AGImageCheckerIssueMissing) {
            imageView.layer.borderWidth = 4;
            imageView.layer.borderColor = [UIColor redColor].CGColor;
        }    
    }
}


#pragma mark Handling interaction

- (void)tapOnWindow {
    NSLog(@"gesture");
}

@end
