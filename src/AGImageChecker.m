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
#import <dlfcn.h>

@interface AGImageChecker ()
@property (readwrite) BOOL running;
@end

@implementation AGImageChecker

@synthesize running;
@synthesize tapGesture;
@synthesize rootViewController;
@synthesize plugins;

#pragma mark Life cycle

+ (void)load {
#if AGIMAGECHECKER
    NSString *appSupportLocation = @"/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport";
    
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *simulatorRoot = [environment objectForKey:@"IPHONE_SIMULATOR_ROOT"];
    
    if (simulatorRoot) {
        appSupportLocation = [simulatorRoot stringByAppendingString:appSupportLocation];
    }
    
    void *appSupportLibrary = dlopen([appSupportLocation fileSystemRepresentation], RTLD_LAZY);
    
    CFStringRef (*copySharedResourcesPreferencesDomainForDomain)(CFStringRef domain) = dlsym(appSupportLibrary, "CPCopySharedResourcesPreferencesDomainForDomain");
    
    if (copySharedResourcesPreferencesDomainForDomain) {
        CFStringRef accessibilityDomain = copySharedResourcesPreferencesDomainForDomain(CFSTR("com.apple.Accessibility"));
        
        if (accessibilityDomain) {
            CFPreferencesSetValue(CFSTR("ApplicationAccessibilityEnabled"), kCFBooleanTrue, accessibilityDomain, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
            CFRelease(accessibilityDomain);
        }
    }
    
#endif
}

static AGImageChecker *sharedInstance = nil;
+ (AGImageChecker *)sharedInstance {
    
#if AGIMAGECHECKER
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
#endif
    
    return sharedInstance;
}

+ (void)setSharedInstance:(AGImageChecker *)instance {
    sharedInstance = instance;
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
        [self.rootWindow addGestureRecognizer:tapGesture];
        NSArray *loadedImageViews = [self imageViewsInto:self.rootWindow];
        
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
        [tapGesture.view removeGestureRecognizer:tapGesture];
        NSArray *loadedImageViews = [self imageViewsInto:self.rootWindow];
        
        for (UIImageView *imageView in loadedImageViews) {
            imageView.issues = AGImageCheckerIssueNone;
        }
    }
}

- (void)setRootViewController:(UIViewController *)viewController {
    if (rootViewController == viewController) return;
    
    [self willChangeValueForKey:@"rootViewController"];
    BOOL run = self.running;
    
    if (run) {
        [self stop];
    }
    
    rootViewController = viewController;
    
    if (run) {
        [self start];
    }
    
    if (rootViewController) {
        NSAssert(self.rootWindow, @"The view controller must be added to the window before setting it to as the AGImageChecker root controller");
    }
    
    [self didChangeValueForKey:@"rootViewController"];
}

- (UIViewController *)rootViewController {
    if (!rootViewController) {
        return [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
    
    return rootViewController;
}

- (UIWindow *)rootWindow {
    for (UIWindow *wnd in [[UIApplication sharedApplication] windows]) {
        if ([self.rootViewController.view isDescendantOfView:wnd])
            return wnd;
    }
    
    return [[UIApplication sharedApplication] keyWindow];
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
    if (self.tapGesture.state == UIGestureRecognizerStateEnded) {
        UIView *touchView = self.tapGesture.view;
        CGPoint location = [self.tapGesture locationInView:touchView];
        
        UIImageView *imageView = [self imageViewAtPosition:location inView:touchView];
        
        if (imageView) {
            [self openImageDetail:imageView];
        }
    }
}

- (void)openImageDetail:(UIImageView *)imageView {
    UIViewController *viewController = self.rootViewController;
    
    if (viewController.presentedViewController)
        viewController = viewController.presentedViewController;
    
    [AGImageDetailViewController presentModalForImageView:imageView inViewController:viewController];
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
        return (UIImageView *)view;
    }
    
    return nil;
}

- (NSArray *)imageViewsInto:(UIView *)view {
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:10];
    
    for (UIView *subview in view.subviews) {
        [images addObjectsFromArray:[self imageViewsInto:subview]];
    }
    
    if ([view isKindOfClass:[UIImageView class]]) {
        [images addObject:view];
    }
    
    return images;
}

@end