//
//  AGImageChecker.m
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageChecker.h"
#import "UIImageView+AGImageChecker.h"
#import "UIImage+AGImageChecker.h"
#import "AGImageDetailViewController.h"
#import "AGImageCheckerBasePlugin.h"

@interface AGImageChecker()
@property(readwrite) BOOL running;
@end

@implementation AGImageChecker

@synthesize running;
@synthesize tapGesture;
@synthesize rootViewController;
@synthesize plugins;

#pragma mark Life cycle

static AGImageChecker *sharedInstance = nil;
+ (AGImageChecker *)sharedInstance
{
#if AGIMAGECHECKER
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
        running = NO;
        tapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnWindow)];
        plugins = [[NSMutableArray alloc] initWithObjects:[[AGImageCheckerBasePlugin alloc] init], nil];
    }
    return self;
}

#pragma mark Public API

- (void)start {
    if (!self.running) {
        self.running = YES;
        [UIImageView startCheckingImages];
        __block id blockSelf = self;
        [UIImageView setImageIssuesHandler:^(UIImageView *imageView) {
            [blockSelf changeIssues:imageView];
        }];
        [UIImageView setImageCheckHandler:^(UIImageView *imageView) {
            [blockSelf checkIssues:imageView];
        }];
        [UIImage startSavingNames];
        [self.rootViewController.view addGestureRecognizer:tapGesture];
        NSArray *loadedImageViews = [self imageViewsInto:self.rootViewController.view];
        for (UIImageView *imageView in loadedImageViews) {
            [self checkIssues:imageView];
        }
    }
}

- (void)stop {
    if (self.running) {
        self.running = NO;
        [UIImageView stopCheckingImages];
        [UIImageView setImageIssuesHandler:nil];
        [UIImageView setImageCheckHandler:nil];
        [UIImage stopSavingNames];
        [self.rootViewController.view removeGestureRecognizer:tapGesture];
        NSArray *loadedImageViews = [self imageViewsInto:self.rootViewController.view];
        for (UIImageView *imageView in loadedImageViews) {
            imageView.issues = AGImageCheckerIssueNone;
        }
    }
}

- (UIViewController *)rootViewController {
    if (!rootViewController) {
        return [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
    return rootViewController;
}

- (void)addPlugin:(id<AGImageCheckerPluginProtocol>)plugin {
    if (![self.plugins containsObject:plugin]) {
        [(NSMutableArray *)self.plugins addObject:plugin];
    }
}

- (void)removePlugin:(id<AGImageCheckerPluginProtocol>)plugin {    
    [(NSMutableArray *)self.plugins removeObject:plugin];
}

#pragma mark Checking and Drawing

- (void)changeIssues:(UIImageView *)imageView  {
    for (id<AGImageCheckerPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(didFinishCalculatingIssues:)]) {
            [plugin didFinishCalculatingIssues:imageView];
        }
    }
}

- (void)checkIssues:(UIImageView *)imageView {
    AGImageCheckerIssue issues = AGImageCheckerIssueNone;
    for (id<AGImageCheckerPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(calculateIssues:withIssues:)]) {
            issues = [plugin calculateIssues:imageView withIssues:issues];
        }
    }
    imageView.issues = issues;
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

- (void)openImageDetail:(UIImageView *)imageView {
    [AGImageDetailViewController presentModalForImageView:imageView inViewController:self.rootViewController];
}


#pragma mark View traversing

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

- (NSArray *)imageViewsInto:(UIView *)view {
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:10];
    for (UIView *subview in view.subviews) {
        [images addObjectsFromArray:[self imageViewsInto:subview]];
    }
    if ([view isKindOfClass:[UIImageView class]]){
        [images addObject:view];
    }
    return images;
}

@end
