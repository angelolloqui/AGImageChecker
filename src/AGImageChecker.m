//
//  AGImageChecker.m
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageChecker.h"
#import "UIImageView+AGImageChecker.h"
#import "AGImageDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AGImageChecker()
@property(readwrite) BOOL running;
@property(readwrite, strong) UILongPressGestureRecognizer *tapGesture;
@end

@implementation AGImageChecker

@synthesize running;
@synthesize tapGesture;
@synthesize rootViewController;

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

- (id)init {
    self = [super init];
    if (self) {
        self.running = NO;
        self.tapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnWindow)];
    }
    return self;
}

#pragma mark Public API

- (void)start {
    if (!self.running) {
        self.running = YES;
        [UIImageView startCheckingImages];
        [UIImageView setImageIssuesHandler:^(UIImageView *imageView, AGImageCheckerIssue issues) {
            [[AGImageChecker sharedInstance] drawIssues:issues forImageView:imageView];
        }];
        [self.rootViewController.view addGestureRecognizer:tapGesture];
    }
}

- (void)stop {
    if (self.running) {
        self.running = NO;
        [UIImageView stopCheckingImages];
        [UIImageView setImageIssuesHandler:nil];
        [self.rootViewController.view removeGestureRecognizer:tapGesture];
    }
}

- (UIViewController *)rootViewController {
    if (!rootViewController) {
        return [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
    return rootViewController;
}

#pragma mark Drawing

- (void)drawIssues:(AGImageCheckerIssue)issues forImageView:(UIImageView *)imageView  {
    
    imageView.layer.borderWidth = 0;
    imageView.layer.borderColor = nil;
    
    if (!imageView.hidden && imageView.alpha > 0) {
        if (issues != AGImageCheckerIssueNone) {
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.1 alpha:0.5].CGColor;
        }
        
        if (issues & AGImageCheckerIssueBlurry) {
            imageView.layer.borderWidth = 2;
            imageView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.1 alpha:0.8].CGColor;
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
    UIView *rootView = self.rootViewController.view;
    CGPoint location = [self.tapGesture locationInView:rootView];
        
    UIImageView *imageView = [self imageViewAtPosition:location inView:rootView];    
    if (imageView) {
        [self openImageDetail:imageView];
    }
}

- (UIImageView *)imageViewAtPosition:(CGPoint)point inView:(UIView *)view {
    NSEnumerator *subviews = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviews) {
        if ((!subview.hidden) &&
            (subview.alpha > 0) &&
            (CGRectContainsPoint(subview.frame, point))) {
            
			CGPoint newPoint = [view convertPoint:point toView:subview];			
            UIImageView *imgView = [self imageViewAtPosition:newPoint inView:subview];
            if (imgView) return imgView;
		}
    }
    
    if ([view isKindOfClass:[UIImageView class]]) {
        return (UIImageView *) view;
    }
    return nil;
}

- (void)openImageDetail:(UIImageView *)imageView {
    [AGImageDetailViewController presentModalForImageView:imageView inViewController:self.rootViewController];
}

@end
