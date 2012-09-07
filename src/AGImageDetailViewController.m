//
//  AGImageDetailViewController.m
//  AGImageChecker
//
//  Created by Angel on 9/7/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageDetailViewController.h"

@interface AGImageDetailViewController ()

@end

@implementation AGImageDetailViewController

#pragma mark Class methods
+ (void)presentModalForImageView:(UIImageView *)imageView inViewController:(UIViewController *)viewController {
    NSAssert(imageView, @"imageView not set");
    NSAssert(viewController, @"viewController not set");
    
    AGImageDetailViewController *vc = [[self alloc] init];    
    [viewController presentModalViewController:vc animated:YES];
}

#pragma mark Instance methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [self.view addGestureRecognizer:tapGesture];
    
}

- (void) dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

@end
