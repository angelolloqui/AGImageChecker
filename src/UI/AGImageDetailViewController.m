//
//  AGImageDetailViewController.m
//  AGImageChecker
//
//  Created by Angel on 9/7/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageDetailViewController.h"
#import "UIImageView+AGImageChecker.h"
#import "AGImageChecker.h"

@interface AGImageDetailViewController () <UIGestureRecognizerDelegate>

@property (readwrite, strong) UIScrollView *contentScrollView;
@property (readwrite, strong) UIImageView *targetImageView;
@property (readwrite, strong) UIActivityIndicatorView *indicator;

@property (assign) AGImageCheckerIssue targetIssues;

@end

@implementation AGImageDetailViewController
@synthesize contentScrollView;
@synthesize targetImageView;
@synthesize targetIssues;
@synthesize indicator;

#pragma mark Class methods
+ (AGImageDetailViewController *)presentModalForImageView:(UIImageView *)imageView inViewController:(UIViewController *)viewController {
    NSAssert(imageView, @"imageView not set");
    NSAssert(viewController, @"viewController not set");
    
    AGImageDetailViewController *vc = [[self alloc] init];
    vc.targetImageView = imageView;
    vc.targetIssues = imageView.issues;
    [viewController presentModalViewController:vc animated:YES];
    return vc;
}

#pragma mark Instance methods

- (void)refreshContentView {
    [self.contentScrollView removeFromSuperview];
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentScrollView];
    
    CGPoint lastPoint = CGPointZero;
    
    for (id<AGImageCheckerPluginProtocol> plugin in [[AGImageChecker sharedInstance] plugins]) {
        if ([plugin respondsToSelector:@selector(detailForViewController:withImageView:withIssues:)]) {
            UIView *view = [plugin detailForViewController:self withImageView:targetImageView withIssues:targetIssues];
            
            if (view) {
                CGRect frame = view.frame;
                frame.origin.y = lastPoint.y;
                view.frame = frame;
                [self.contentScrollView addSubview:view];
                lastPoint.y = CGRectGetMaxY(frame);
                lastPoint.x = MAX(lastPoint.x, CGRectGetMaxX(frame));
            }
        }
    }
    
    self.contentScrollView.contentSize = CGSizeMake(lastPoint.x, lastPoint.y);
    [self.view bringSubviewToFront:self.indicator];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.center = self.view.center;
    self.indicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.indicator.hidesWhenStopped = YES;
    [self.indicator stopAnimating];
    [self.view addSubview:indicator];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[AGImageChecker sharedInstance] stop];
    [self refreshContentView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[AGImageChecker sharedInstance] start];
}

- (void)dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]])
        return NO;
    
    return YES;
}

@end