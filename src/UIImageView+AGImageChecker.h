//
//  UIImageView+AGImageChecker.h
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    AGImageCheckerIssueNone,
    AGImageCheckerIssueResized = 1 << 1,
    AGImageCheckerIssueBlurry = 1 << 2,
    AGImageCheckerIssueStretched = 1 << 3,
    AGImageCheckerIssuePartiallyHidden = 1 << 4,
    AGImageCheckerIssueMissaligned = 1 << 5,
    AGImageCheckerIssueMissing = 1 << 6
}AGImageCheckerIssue;

typedef void(^AGImageIssuesHandler)(UIImageView *imageView, AGImageCheckerIssue issues);

@interface UIImageView (AGImageChecker)

@property (assign) AGImageCheckerIssue issues;

+ (void)startCheckingImages;
+ (void)stopCheckingImages;
+ (void)setImageIssuesHandler:(AGImageIssuesHandler)handler;

- (void)checkImage;

@end
