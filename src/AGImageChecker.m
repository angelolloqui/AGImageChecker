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

- (void)start {
    [UIImageView startCheckingImages];
    [UIImageView setImageIssuesHandler:^(UIImageView *imageView, AGImageCheckerIssue issues) {
        [[AGImageChecker sharedInstance] drawIssues:issues forImageView:imageView];
    }];
}

- (void)stop {
    [UIImageView stopCheckingImages];
    [UIImageView setImageIssuesHandler:nil];
}


#pragma mark Drawing and notifiying

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




@end
