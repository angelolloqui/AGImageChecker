//
//  UIImageView+AGImageChecker.h
//  Ziggo TV
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    AGImageCheckerIssueNone,
    AGImageCheckerIssueResized = 1 << 1,
    AGImageCheckerIssueBlurry = 1 << 2,
    AGImageCheckerIssueStretched = 1 << 3,
    AGImageCheckerIssuePartiallyHidden = 1 << 4,
    AGImageCheckerIssueMissing = 1 << 5
}AGImageCheckerIssue;

@interface UIImageView (AGImageChecker)

@property (assign) AGImageCheckerIssue issues;

+ (void)startCheckingImages;
+ (void)stopCheckingImages;

@end
